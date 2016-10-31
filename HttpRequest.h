//
//  HttpRequest.h
//  CWZProfessional
//
//  Created by wharlim on 16/9/6.
//  Copyright © 2016年 cwz100. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(NSDictionary *respondDict, BOOL success); // 访问成功block
typedef void (^AFNErrorBlock)(NSError *error); // 访问失败block

@class HttpRequestConfiguration;

@interface HttpRequest : NSObject

#pragma mark - POST

+(void)postUserDataWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)param hub:(BOOL)showHub Success:(SuccessBlock)success fail:(AFNErrorBlock)fail;

+(void)postRawDataWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)param hub:(BOOL)showHub Success:(SuccessBlock)success fail:(AFNErrorBlock)fail;

///post JSON串字符串到服务器
+(void)postUserDataOnJsonStrWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)param hub:(BOOL)showHub Success:(SuccessBlock)success fail:(AFNErrorBlock)fail;


///图片上传,单张或多张都行
+(void)postImageWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)params JPEGData:(id)data Success:(SuccessBlock)success fail:(AFNErrorBlock)fail;

///静默上传数据
+(void)silencePostUserDataWithUrlPath:(NSString *)urlPath Param:(NSDictionary *)param Success:(SuccessBlock)success fail:(AFNErrorBlock)fail;




@end


///HttpRequest 配置类
@interface HttpRequestConfiguration : NSObject

@property (nonatomic,copy) NSString *postMethod;


@end