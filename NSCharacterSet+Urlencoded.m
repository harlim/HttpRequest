//
//  NSCharacterSet+Urlencoded.m
//  myTest
//
//  Created by wharlim on 16/10/26.
//  Copyright © 2016年 wharlim. All rights reserved.
//

#import "NSCharacterSet+Urlencoded.h"

@implementation NSCharacterSet (Urlencoded)

+ (NSCharacterSet *)URLEncodedAllowedCharacterSet{
    return [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"];
}

@end
