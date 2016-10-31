//
//  NSCharacterSet+Urlencoded.h
//  myTest
//
//  Created by wharlim on 16/10/26.
//  Copyright © 2016年 wharlim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (Urlencoded)

///返回url的未保留字符,详情见：https://zh.wikipedia.org/wiki/%E7%99%BE%E5%88%86%E5%8F%B7%E7%BC%96%E7%A0%81
+ (NSCharacterSet *)URLEncodedAllowedCharacterSet;


@end
