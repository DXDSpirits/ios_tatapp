//
//  WedfairyUserDefaults.m
//  Wedfairy
//
//  Created by Fei Wen on 7/28/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import "WedfairyUserDefaults.h"

@implementation WedfairyUserDefaults

@dynamic wechat_auth_url;
@dynamic back_from_wechat_login;
@dynamic will_go_wechat_login;
@dynamic first_time_use;

+ (instancetype)standardUserDefaults {
    static dispatch_once_t onceToken;
    static WedfairyUserDefaults *defaultStorage = nil;
    dispatch_once(&onceToken, ^{
        defaultStorage = [[self alloc] init];
    });
    
    return defaultStorage;
}

- (NSDictionary *)setupDefaults {
    return @{@"wechat_auth_url" : @"",
             @"back_from_wechat_login" : @(NO),
             @"_will_go_wechat_login": @(NO),
             @"first_time_use" : @(YES),
             @"user_cancelled" : @(NO)};
}


@end
