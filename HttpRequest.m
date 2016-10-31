//
//  HttpRequest.m
//  CWZProfessional
//
//  Created by wharlim on 16/9/6.
//  Copyright © 2016年 cwz100. All rights reserved.
//

#import "HttpRequest.h"
#import "NSCharacterSet+Urlencoded.h"


#define kTimeOutInterval 10 // 请求超时的时间


@implementation HttpRequest



#pragma mark - POST

+(void)postUserDataWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)param hub:(BOOL)showHub Success:(SuccessBlock)success fail:(AFNErrorBlock)fail{
    //添加token
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{@"token":[CWZ_Account currentAccount].user.sessionid}];
    [params addEntriesFromDictionary:param];
    
    [self postRawDataWithUrlPath:urlPath Param:params hub:showHub Success:success fail:fail];
}

+(void)postRawDataWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)param hub:(BOOL)showHub Success:(SuccessBlock)success fail:(AFNErrorBlock)fail{
    
    //添加时间字符串
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{@"timestamp":[self getTimeFormatNow]}];
    [params addEntriesFromDictionary:param];
    
    
    if ([urlPath hasPrefix:@"http://"] || [urlPath hasPrefix:@"https://"]) {            //如果是完整的url就
        [self postDataWithUrl:urlPath Param:params Configuration:nil hub:showHub Success:success fail:fail];
    }else{
        NSString *url = [API_PRE stringByAppendingString:urlPath];                      //不完整就添加
        [self postDataWithUrl:url Param:params Configuration:nil hub:showHub Success:success fail:fail];
    }
}

///post JSON串字符串到服务器
+(void)postUserDataOnJsonStrWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)param hub:(BOOL)showHub Success:(SuccessBlock)success fail:(AFNErrorBlock)fail{
    //添加token
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{@"token":[CWZ_Account currentAccount].user.sessionid}];
    [params addEntriesFromDictionary:param];
    
    [params addEntriesFromDictionary:@{@"timestamp":[self getTimeFormatNow]}];
    [params addEntriesFromDictionary:param];
    
    HttpRequestConfiguration *configuration = [[HttpRequestConfiguration alloc] init];
    configuration.postMethod = @"JSON";
    if ([urlPath hasPrefix:@"http://"] || [urlPath hasPrefix:@"https://"]) {            //如果是完整的url就
        [self postDataWithUrl:urlPath Param:params Configuration:configuration hub:showHub Success:success fail:fail];
    }else{
        NSString *url = [API_PRE stringByAppendingString:urlPath];                      //不完整就添加
        [self postDataWithUrl:url Param:params Configuration:configuration hub:showHub Success:success fail:fail];
    }
    
}

+(void)postDataWithUrl:(NSString *)url Param:(NSDictionary *)params Configuration:(HttpRequestConfiguration *)configuration hub:(BOOL)showHub Success:(SuccessBlock)success fail:(AFNErrorBlock)fail{
    if(showHub)[SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    if(showHub)[SVProgressHUD show];
    NSMutableURLRequest *mURLRequest = [self configMutableRequestWithUrlPath:url Param:params Configuration:configuration];
    //不设置缓存
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    [[urlSession dataTaskWithRequest:mURLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{    //主线程更新
            if (error) {        //网络层错误
                if (fail) {
                    if(showHub)[SVProgressHUD showErrorWithStatus:error.localizedDescription];
                    fail(error);
                }else{
                    [SVProgressHUD showErrorWithStatus:@"网络出错"];
                }
            }else{
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (dic) {
                    if (dic[@"status"]) {
                        NSInteger status = [dic[@"status"] integerValue];   //错误码
                        if ([self checkStatusCode:status]) {
                            success(dic,YES);
                        }
                    }else{
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"数据出错，没有状态码"]];     //服务器逻辑层出错,没有状态码
                    }
                }else{
                    //服务器出错，返回的不是json数据
                    [SVProgressHUD showErrorWithStatus:@"服务器出错"];
                }
                
            }
 
        });
        
    }] resume];
 
}


///静默上传数据
+(void)silencePostUserDataWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)param Success:(SuccessBlock)success fail:(AFNErrorBlock)fail{
    //添加token
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([CWZ_Account currentAccount].user.sessionid) {
        [params addEntriesFromDictionary:@{@"token":[CWZ_Account currentAccount].user.sessionid}];
        [params addEntriesFromDictionary:param];
    }
    
    //添加时间字符串
    [params addEntriesFromDictionary:@{@"timestamp":[self getTimeFormatNow]}];
    if ([urlPath hasPrefix:@"http://"] || [urlPath hasPrefix:@"https://"]) {
    }else{
        urlPath = [API_PRE stringByAppendingString:urlPath];                      //不完整就添加
    }
    
    NSMutableURLRequest *mURLRequest = [self configMutableRequestWithUrlPath:urlPath Param:params Configuration:nil];
    //不设置缓存
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    [[urlSession dataTaskWithRequest:mURLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{    //主线程更新
            if (!error) {        //网络层错误
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (dic) {
                    if (dic[@"status"]) {
                        NSInteger status = [dic[@"status"] integerValue];   //错误码
                        if ([self checkStatusCode:status]) {
                            success(dic,YES);
                        }
                    }
                }
            }
        });
    }] resume];
    
}

///图片上传
+(void)postImageWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)params JPEGData:(id)data Success:(SuccessBlock)success fail:(AFNErrorBlock)fail{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:@{@"timestamp":[self getTimeFormatNow]}];                         //添加时间字符串
    [dic addEntriesFromDictionary:@{@"type":@"2"}];     //添加type
    if ([CWZ_Account currentAccount].user) {
        [dic addEntriesFromDictionary:@{@"token":[CWZ_Account currentAccount].user.sessionid}];     //添加token
    }
    if (params){
        [dic addEntriesFromDictionary:params];
    }
    NSString *url = [API_PRE stringByAppendingString:urlPath];
    
    NSString *boundary = [[NSUUID UUID] UUIDString];
    NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:0 timeoutInterval:kTimeOutInterval];
    mURLRequest.HTTPMethod = @"POST";
    [mURLRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    //不设置缓存
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    [[urlSession uploadTaskWithRequest:mURLRequest
                             fromData:[self createBodyWithParameters:dic JPEGData:data boundary:boundary]
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        
                        
                        if (error) {        //网络层错误
                            if (fail) {
                                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                fail(error);
                            }else{
                                [SVProgressHUD showErrorWithStatus:@"网络出错"];
                            }
                        }else{
                            
                            
                            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            if (dic) {
                                if (dic[@"status"]) {
                                    //                    if(showHub)[SVProgressHUD dismiss];
                                    NSInteger status = [dic[@"status"] integerValue];   //错误码
                                    if ([self checkStatusCode:status]) {
                                        success(dic,YES);
                                        return ;          //一切正常，退出流程
                                    }
                                }else{
                                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"数据出错，没有状态码"]];     //服务器逻辑层出错,没有状态码
                                }
                            }else{
                                //服务器出错，返回的不是json数据
                                [SVProgressHUD showErrorWithStatus:@"服务器出错"];
                            }
                            
                        }
                    
     
    }] resume];
    
    
    
}

+(NSMutableData *)createBodyWithParameters:(NSDictionary *)param JPEGData:(id)data boundary:(NSString *)boundary{
    
    NSMutableData *body = [NSMutableData data];
    if (param) {                                //添加参数
        for (NSString *key in param) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n",param[key]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    //添加图片
    NSArray *dataArray = data;
    if (![data isKindOfClass:[NSArray class]]) {
        dataArray = @[data];
    }
    for (int i = 0; i < [dataArray count]; i++) {
        id obj = dataArray[i];
        if ([obj isKindOfClass:[UIImage class]]) {
            obj = UIImageJPEGRepresentation(obj, 1);
        }
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file%d\"; filename=\"file%d.jpg\"\r\n",i,i] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:obj];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
    
}

+(NSMutableURLRequest *)configMutableRequestWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)params Configuration:(HttpRequestConfiguration *)configuration{
        //初始化 NSMutableURLRequest
    NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlPath] cachePolicy:0 timeoutInterval:kTimeOutInterval];
    mURLRequest.HTTPMethod = @"POST";
    
    if (configuration && [configuration.postMethod isEqualToString:@"JSON"]) {
        //在 HTTPBody里面添加 JSON串
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        mURLRequest.HTTPBody = jsonData;
        [mURLRequest addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }else if(params){
        //----------------组装完整url
        NSMutableArray *paramsArray = [@[] mutableCopy];
        for (NSString *key in params) {
            //urlencoded url编码
            NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:[key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLEncodedAllowedCharacterSet]] value:[params[key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLEncodedAllowedCharacterSet]]];
            [paramsArray addObject:item];
        }
        NSURLComponents *urlComponents = [NSURLComponents componentsWithString:urlPath];
        if (urlComponents.queryItems) {
            [paramsArray addObjectsFromArray:urlComponents.queryItems];
        }
        urlComponents.queryItems = paramsArray;
        //----------------组装完整url
        mURLRequest.HTTPBody =  [urlComponents.query dataUsingEncoding:NSUTF8StringEncoding];
    }
    return mURLRequest;
}


#pragma mark - other method

///获取年月日时分秒
+(NSString *)getTimeFormatNow{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    NSInteger day = [dateComponent day];
    NSInteger hour = [dateComponent hour];
    NSInteger minute = [dateComponent minute];
    NSInteger second = [dateComponent second];
    NSString *timeFormat = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld",year,month,day,hour,minute,second];
    return timeFormat;
}


///查询状态码
+(BOOL)checkStatusCode:(NSInteger)status{
    switch (status) {
        case 200:       //一切正常
            [SVProgressHUD dismiss];
            return YES;
            break;
        case 201:{
            [SVProgressHUD showErrorWithStatus:@"签名错误"];
            break;
        }
        case 210:{
            [SVProgressHUD showErrorWithStatus:@"appkey不正确"];
            break;
        }
        case 211:{
            [SVProgressHUD showErrorWithStatus:@"接口调用失效"];
            break;
        }
        case 212:{
            [SVProgressHUD showErrorWithStatus:@"签名错误"];
            break;
        }
        case 213:{
            [SVProgressHUD showErrorWithStatus:@"参数异常"];
            break;
        }
        case 214:{      //token失效，强制注销，要重新登录
            [SVProgressHUD showErrorWithStatus:@"token失效,要重新登录"];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGINOUT_STRING object:nil]; //发起注销通知
            break;
        }
        case 215:{
            [SVProgressHUD showErrorWithStatus:@"验证码已过期"];
            break;
        }
        case 216:{
            [SVProgressHUD showErrorWithStatus:@"验证码已发送"];
            break;
        }
        case 217:{
            [SVProgressHUD showErrorWithStatus:@"验证码错误"];
            break;
        }
            
            
            /**-----------------------------文件上传---------------------------**/
        case 310:{
            [SVProgressHUD showErrorWithStatus:@"上传文件不存在"];
            break;
        }
        case 311:{
            [SVProgressHUD showErrorWithStatus:@"上传类型不合法"];
            break;
        }
        case 312:{
            [SVProgressHUD showErrorWithStatus:@"上传文件过大"];
            break;
        }
            
            
            /**-----------------------------用户相关---------------------------**/
        case 410:{
            [SVProgressHUD showErrorWithStatus:@"用户名或密码错误"];
            break;
        }
        case 411:{
            [SVProgressHUD showErrorWithStatus:@"用户被禁用"];
            break;
        }
        case 413:{
            [SVProgressHUD showErrorWithStatus:@"注册用户已存在"];
            break;
        }
        case 414:{
            [SVProgressHUD showErrorWithStatus:@"用户不存在"];
            break;
        }
        case 415:{
            [SVProgressHUD showErrorWithStatus:@"修改密码失败"];
            break;
        }
        case 416:{
            [SVProgressHUD showErrorWithStatus:@"密码不是6位"];
            break;
        }
            
            
            /**---------------------------- 商家专家相关------------------------**/
        case 501:{
            [SVProgressHUD showErrorWithStatus:@"商家已认证中"];
            break;
        }
        case 502:{
            [SVProgressHUD showErrorWithStatus:@"商家已报价过该比价"];
            break;
        }
        case 503:{
            [SVProgressHUD showErrorWithStatus:@"账号尚未认证，请认证后再操作"];
            break;
        }
        case 504:{
            [SVProgressHUD showErrorWithStatus:@"专家提交认证失败"];
            break;
        }
        case 505:{
            [SVProgressHUD showErrorWithStatus:@"技师信息修改失败"];
            break;
        }
            
            /**-----------------------------问诊核单相关---------------------------**/
        case 601:{
            [SVProgressHUD showErrorWithStatus:@"问诊采纳失败"];
            break;
        }
        case 602:{
            [SVProgressHUD showErrorWithStatus:@"提问失败"];
            break;
        }
            
        case 603:{
            [SVProgressHUD showErrorWithStatus:@"比价采纳失败"];
            break;
        }
        case 604:{
            [SVProgressHUD showErrorWithStatus:@"提出比价失败"];
            break;
        }
            
        case 605:{
            [SVProgressHUD showErrorWithStatus:@"问诊答复失败"];
            break;
        }
        case 606:{
            [SVProgressHUD showErrorWithStatus:@"重复答复"];
            break;
        }
        case 608:{
            [SVProgressHUD showErrorWithStatus:@"改装图片不足"];
            break;
        }
            
            /**-----------------------------商品相关---------------------------**/
        case 703:{
            [SVProgressHUD showErrorWithStatus:@"修改商品失败"];
            break;
        }
            
            
            
        default:
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"未知错误\n状态码：%ld",status]];
            break;
    }
    return NO;
}



@end



@implementation HttpRequestConfiguration


@end














