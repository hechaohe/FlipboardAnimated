//
//  User.h
//  KeyChainDemo
//
//  Created by 贺超 on 2018/3/21.
//  Copyright © 2018年 贺超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject


+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
