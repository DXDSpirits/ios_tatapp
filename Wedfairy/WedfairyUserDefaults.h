//
//  WedfairyUserDefaults.h
//  Wedfairy
//
//  Created by Fei Wen on 7/28/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import <GVUserDefaults.h>

@interface WedfairyUserDefaults : GVUserDefaults

@property (nonatomic, readwrite) NSString *wechat_auth_url;
@property (nonatomic, readwrite) BOOL back_from_wechat_login;

@end
