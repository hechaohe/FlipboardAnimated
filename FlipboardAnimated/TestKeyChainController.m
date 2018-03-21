//
//  TestKeyChainController.m
//  FlipboardAnimated
//
//  Created by 贺超 on 2018/3/21.
//  Copyright © 2018年 贺超. All rights reserved.
//

#import "TestKeyChainController.h"
#import <Security/Security.h>

#import "User.h"


@interface TestKeyChainController ()

@end

@implementation TestKeyChainController

/** 增/改 */
- (IBAction)insertAndUpdate:(id)sender {
    
    /**
     说明：当添加的时候我们一般需要判断一下当前钥匙串里面是否已经存在我们要添加的钥匙。如果已经存在我们就更新好了，不存在再添加，所以这两个操作一般写成一个函数搞定吧。
     
     过程关键：1.检查是否已经存在 构建的查询用的操作字典：kSecAttrService，kSecAttrAccount，kSecClass（标明存储的数据是什么类型，值为kSecClassGenericPassword 就代表一般的密码）
     
     　　　2.添加用的操作字典：　kSecAttrService，kSecAttrAccount，kSecClass，kSecValueData
     
     　　　3.更新用的操作字典1（用于定位需要更改的钥匙）：kSecAttrService，kSecAttrAccount，kSecClass
     
     　　　　　　　　操作字典2（新信息）kSecAttrService，kSecAttrAccount，kSecClass ,kSecValueData
     */
    
    NSLog(@"插入 : %d",  [self addItemWithService:@"com.tencent" account:@"李雷" password:@"911"]);
}

-(BOOL)addItemWithService:(NSString *)service account:(NSString *)account password:(NSString *)password{
    
    //先查查是否已经存在
    //构造一个操作字典用于查询
    
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    
    [queryDic setObject:service forKey:(__bridge id)kSecAttrService];                         //标签service
    [queryDic setObject:account forKey:(__bridge id)kSecAttrAccount];                         //标签account
    [queryDic setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];//表明存储的是一个密码
    
    OSStatus status = -1;
    CFTypeRef result = NULL;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDic, &result);
    
    if (status == errSecItemNotFound) {                                              //没有找到则添加
        
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];    //把password 转换为 NSData
        
        [queryDic setObject:passwordData forKey:(__bridge id)kSecValueData];       //添加密码
        
        status = SecItemAdd((__bridge CFDictionaryRef)queryDic, NULL);             //!!!!!关键的添加API
        
    }else if (status == errSecSuccess){                                              //成功找到，说明钥匙已经存在则进行更新
        
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];    //把password 转换为 NSData
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:queryDic];
        
        [dict setObject:passwordData forKey:(__bridge id)kSecValueData];             //添加密码
        
        status = SecItemUpdate((__bridge CFDictionaryRef)queryDic, (__bridge CFDictionaryRef)dict);//!!!!关键的更新API
        
    }
    
    return (status == errSecSuccess);
}


/** 查 */
- (IBAction)select:(id)sender {
    
    /**
     过程：
     1.(关键)先配置一个操作字典内容有:
     kSecAttrService(属性),kSecAttrAccount(属性) 这些属性or标签是查找的依据
     kSecReturnData(值为@YES 表明返回类型为data),kSecClass(值为kSecClassGenericPassword 表示重要数据为“一般密码”类型) 这些限制条件是返回结果类型的依据
     
     2.然后用查找的API 得到查找状态和返回数据（密码）
     
     3.最后如果状态成功那么将数据（密码）转换成string 返回
     */
    
    NSLog(@"%@", [self passwordForService:@"com.tencent" account:@"李雷"]);
    
}

//用原生的API 实现查询密码
- (NSString *)passwordForService:(nonnull NSString *)service account:(nonnull NSString *)account{
    
    //生成一个查询用的 可变字典
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    
    //首先添加获取密码所需的搜索键和类属性：
    [queryDic setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass]; //表明为一般密码可能是证书或者其他东西
    [queryDic setObject:(__bridge id)kCFBooleanTrue  forKey:(__bridge id)kSecReturnData];     //返回Data
    
    [queryDic setObject:service forKey:(__bridge id)kSecAttrService];    //输入service
    [queryDic setObject:account forKey:(__bridge id)kSecAttrAccount];  //输入account
    
    //查询
    OSStatus status = -1;
    CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDic,&result);//核心API 查找是否匹配 和返回密码！
    if (status != errSecSuccess) { //判断状态
        
        return nil;
    }
    //返回数据
    //    NSString *password = [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];//转换成string
    
    //删除kSecReturnData键; 我们不需要它了：
    [queryDic removeObjectForKey:(__bridge id)kSecReturnData];
    //将密码转换为NSString并将其添加到返回字典：
    NSString *password = [[NSString alloc] initWithBytes:[(__bridge_transfer NSData *)result bytes] length:[(__bridge NSData *)result length] encoding:NSUTF8StringEncoding];
    
    [queryDic setObject:password forKey:(__bridge id)kSecValueData];
    
    NSLog(@"查询 : %@", queryDic);
    
    
    return password;
}


/** 删 */
//- (IBAction)delete:(id)sender {
//
//    NSLog(@"删除 : %d", [self deleteItemWithService:@"com.tencent" account:@"李雷"]);
//}


-(BOOL)deleteItemWithService:(NSString *)service account:(NSString *)account{
    
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    
    [queryDic setObject:service forKey:(__bridge id)kSecAttrService];                         //标签service
    [queryDic setObject:account forKey:(__bridge id)kSecAttrAccount];                         //标签account
    [queryDic setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];//表明存储的是一个密码
    
    
    OSStatus status = SecItemDelete((CFDictionaryRef)queryDic);
    
    return (status == errSecSuccess);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (IBAction)add:(id)sender {
    
    NSLog(@"新增：%d",[self hc_addItemWithService:@"com.baidu" account:@"zhangsan" password:@"1234567"]);
    //    [self hc_addItemWithService:@"com.baidu" account:@"zhangsan" password:@"123"];
    
}

- (IBAction)query:(id)sender {
    
    NSLog(@"%@",[self hc_passwordForService:@"com.baidu" account:@"zhangsan"]);
    
    //    [self hc_passwordForService:@"com.baidu" account:@"zhangsan"];
    
    
    
}
- (IBAction)delete:(id)sender {
    
    NSLog(@"%d",[self hc_deleteItemWithService:@"com.baidu" account:@"zhangsan"]);
    
}


- (BOOL)hc_addItemWithService:(NSString *)service account:(NSString *)account password:(NSString *)password {
    
    
    //    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    //
    //    [dict setObject:service forKey:((__bridge id)kSecAttrService)];
    //    [dict setObject:account forKey:((__bridge id)kSecAttrAccount)];
    //    [dict setObject:((__bridge id)kSecClassGenericPassword) forKey:((__bridge id)kSecClass)];
    //
    //    OSStatus status = -1;
    //    CFTypeRef result = NULL;
    //
    //    status = SecItemCopyMatching((__bridge CFDictionaryRef)dict, &result);
    //
    //    if (status == errSecItemNotFound ) {
    //        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    //        [dict setObject:passwordData forKey:(__bridge id)kSecValueData];
    //        status = SecItemAdd((__bridge CFDictionaryRef)dict, NULL);
    //
    //    } else if (status == errSecSuccess) {
    //        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    //        NSMutableDictionary *successDic = [[NSMutableDictionary alloc] initWithDictionary:dict];
    //        [successDic setObject:passwordData forKey:(__bridge id)kSecValueData];
    //        status = SecItemUpdate((__bridge CFDictionaryRef)dict, (__bridge CFDictionaryRef)successDic);
    //
    //    }
    //
    //    return (status = errSecSuccess);
    //
    
    
    
    
    
    //先查查是否已经存在
    //构造一个操作字典用于查询
    
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    
    [queryDic setObject:service forKey:(__bridge id)kSecAttrService];                         //标签service
    [queryDic setObject:account forKey:(__bridge id)kSecAttrAccount];                         //标签account
    [queryDic setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];//表明存储的是一个密码
    
    OSStatus status = -1;
    CFTypeRef result = NULL;
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDic, &result);
    
    if (status == errSecItemNotFound) {                                              //没有找到则添加
        
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];    //把password 转换为 NSData
        
        [queryDic setObject:passwordData forKey:(__bridge id)kSecValueData];       //添加密码
        
        status = SecItemAdd((__bridge CFDictionaryRef)queryDic, NULL);             //!!!!!关键的添加API
        
    }else if (status == errSecSuccess){                                              //成功找到，说明钥匙已经存在则进行更新
        
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];    //把password 转换为 NSData
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:queryDic];
        
        [dict setObject:passwordData forKey:(__bridge id)kSecValueData];             //添加密码
        
        status = SecItemUpdate((__bridge CFDictionaryRef)queryDic, (__bridge CFDictionaryRef)dict);//!!!!关键的更新API
        
    }
    
    return (status == errSecSuccess);
    
    
    
}

- (NSString *)hc_passwordForService:(NSString *)service account:(NSString *)account {
    
    //    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    //
    //    [dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    //    [dict setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    //
    //    [dict setObject:service forKey:(__bridge id)kSecAttrService];
    //    [dict setObject:account forKey:(__bridge id)kSecAttrAccount];
    //
    //
    //    OSStatus  status = -1;
    //    CFTypeRef result = NULL;
    //
    //    status = SecItemCopyMatching((__bridge CFDictionaryRef)dict, &result);
    //    if (status != errSecSuccess) {
    //        return nil;
    //    }
    //
    //    [dict removeObjectForKey:(__bridge id)kSecReturnData];
    //
    //    NSString *password = [[NSString alloc] initWithBytes:[(__bridge_transfer NSData *)result bytes] length:[(__bridge_transfer NSData *)result length] encoding:NSUTF8StringEncoding];
    //
    //
    //    [dict setObject:password forKey:(__bridge id)kSecValueData];
    //
    //    return password;
    //
    
    
    //生成一个查询用的 可变字典
    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    
    //首先添加获取密码所需的搜索键和类属性：
    [queryDic setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass]; //表明为一般密码可能是证书或者其他东西
    [queryDic setObject:(__bridge id)kCFBooleanTrue  forKey:(__bridge id)kSecReturnData];     //返回Data
    
    [queryDic setObject:service forKey:(__bridge id)kSecAttrService];    //输入service
    [queryDic setObject:account forKey:(__bridge id)kSecAttrAccount];  //输入account
    
    //查询
    OSStatus status = -1;
    CFTypeRef result = NULL;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDic,&result);//核心API 查找是否匹配 和返回密码！
    if (status != errSecSuccess) { //判断状态
        
        return nil;
    }
    //返回数据
    //    NSString *password = [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];//转换成string
    
    //删除kSecReturnData键; 我们不需要它了：
    [queryDic removeObjectForKey:(__bridge id)kSecReturnData];
    //将密码转换为NSString并将其添加到返回字典：
    NSString *password = [[NSString alloc] initWithBytes:[(__bridge_transfer NSData *)result bytes] length:[(__bridge NSData *)result length] encoding:NSUTF8StringEncoding];
    
    [queryDic setObject:password forKey:(__bridge id)kSecValueData];
    
    NSLog(@"查询 : %@", queryDic);
    
    
    return password;
    
    
}

- (BOOL)hc_deleteItemWithService:(NSString *)service account:(NSString *)account {
    //    NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
    //
    //    [queryDic setObject:service forKey:(__bridge id)kSecAttrService];                         //标签service
    //    [queryDic setObject:account forKey:(__bridge id)kSecAttrAccount];                         //标签account
    //    [queryDic setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];//表明存储的是一个密码
    //
    //
    //    OSStatus status = SecItemDelete((CFDictionaryRef)queryDic);
    //
    //    return (status == errSecSuccess);
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [dict setObject:service forKey:(__bridge id)kSecAttrService];
    [dict setObject:account forKey:(__bridge id)kSecAttrAccount];
    [dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    OSStatus status = SecItemDelete((CFDictionaryRef)dict);
    
    return (status == errSecSuccess);
    
    
    
}


NSString * const KEY_USERNAME_PASSWORD = @"com.company.app.usernamepassword";
NSString * const KEY_USERNAME = @"com.company.app.username";
NSString * const KEY_PASSWORD = @"com.company.app.password";


- (void)test {
    // 调用
    NSMutableDictionary *userNamePasswordKVPairs = [NSMutableDictionary dictionary];
    [userNamePasswordKVPairs setObject:@"userName" forKey:KEY_USERNAME];
    [userNamePasswordKVPairs setObject:@"password11111" forKey:KEY_PASSWORD];
    NSLog(@"%@", userNamePasswordKVPairs); //有KV值
    
    // A、将用户名和密码写入keychain
    [User save:KEY_USERNAME_PASSWORD data:userNamePasswordKVPairs];
    
    // B、从keychain中读取用户名和密码
    NSMutableDictionary *readUsernamePassword = (NSMutableDictionary *)[User load:KEY_USERNAME_PASSWORD];
    NSString *userName = [readUsernamePassword objectForKey:KEY_USERNAME];
    NSString *password = [readUsernamePassword objectForKey:KEY_PASSWORD];
    NSLog(@"username = %@", userName);
    NSLog(@"password = %@", password);
    
    // C、将用户名和密码从keychain中删除
    [User delete:KEY_USERNAME_PASSWORD];
    
    
}

- (IBAction)add1:(id)sender {
    NSMutableDictionary *userNamePasswordKVPairs = [NSMutableDictionary dictionary];
    [userNamePasswordKVPairs setObject:@"userName" forKey:KEY_USERNAME];
    [userNamePasswordKVPairs setObject:@"password11111" forKey:KEY_PASSWORD];
    NSLog(@"%@", userNamePasswordKVPairs); //有KV值
    
    // A、将用户名和密码写入keychain
    [User save:KEY_USERNAME_PASSWORD data:userNamePasswordKVPairs];
}
- (IBAction)query1:(id)sender {
    // B、从keychain中读取用户名和密码
    NSMutableDictionary *readUsernamePassword = (NSMutableDictionary *)[User load:KEY_USERNAME_PASSWORD];
    NSString *userName = [readUsernamePassword objectForKey:KEY_USERNAME];
    NSString *password = [readUsernamePassword objectForKey:KEY_PASSWORD];
    NSLog(@"username = %@", userName);
    NSLog(@"password = %@", password);
}
- (IBAction)delete1:(id)sender {
    // C、将用户名和密码从keychain中删除
    [User delete:KEY_USERNAME_PASSWORD];
}



@end
