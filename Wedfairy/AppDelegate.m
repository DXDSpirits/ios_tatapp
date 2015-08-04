//
//  AppDelegate.m
//  Wedfairy
//
//  Created by Fei Wen on 7/9/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "MainViewController.h"
#import "WedfairyUserDefaults.h"
#import <PgySDK/PgyManager.h>

@interface AppDelegate ()

@property (nonatomic) UIViewController *lastVC;
@property (nonatomic, retain) NSURL *currentURL;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [WedfairyUserDefaults standardUserDefaults].back_from_wechat_login = NO;
    [UMSocialData setAppKey:@"55ab622967e58e5411005fde"];
    [UMSocialWechatHandler setWXAppId:@"wx3e57b873d623a4a3" appSecret:@"7b4516c6814fce606faefd3393179a30" url:@"http://www.wedfairy.com"];
    [[PgyManager sharedPgyManager] startManagerWithAppId:@"4c1f91082f65e0f49425309e5bdf88bf"];
    
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToWechatSession,UMShareToWechatTimeline]];
    [WXApi registerApp:@"wx3e57b873d623a4a3"];
    // Override point for customization after application launch.
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    //MainViewController *mVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
    return ([UMSocialSnsService handleOpenURL:url] || [WXApi handleOpenURL:url delegate:self]);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    //MainViewController *mVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
    return  [UMSocialSnsService handleOpenURL:url] || [WXApi handleOpenURL:url delegate:self];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _lastVC = ((UINavigationController*)self.window.rootViewController).visibleViewController;
    if ([_lastVC isKindOfClass: [MainViewController class]] && [WedfairyUserDefaults standardUserDefaults].will_go_wechat_login){
        [(MainViewController *)_lastVC loadNewPage:[NSURL URLWithString:@"about:blank"]];
        [WedfairyUserDefaults standardUserDefaults].will_go_wechat_login = NO;
    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([_lastVC isKindOfClass: [MainViewController class]]) {
        NSString *url_string = [WedfairyUserDefaults standardUserDefaults].wechat_auth_url;
        if (url_string && ([WedfairyUserDefaults standardUserDefaults].back_from_wechat_login || [WedfairyUserDefaults standardUserDefaults].user_cancelled)) {
            [(MainViewController *)_lastVC loadNewPage:[NSURL URLWithString:url_string]];
            [WedfairyUserDefaults standardUserDefaults].wechat_auth_url = nil;
            [WedfairyUserDefaults standardUserDefaults].back_from_wechat_login = NO;
            [WedfairyUserDefaults standardUserDefaults].user_cancelled = NO;
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - WXApiDelegate

-(void) onReq:(SendAuthResp *)req{
    NSLog(@"Call req");
}

-(void) onResp:(SendAuthResp *)resp{
    NSLog(@"Response: %@, %d", resp, resp.errCode);

    if (resp.errCode == 0) {
        [WedfairyUserDefaults standardUserDefaults].wechat_auth_url = [[NSString stringWithFormat:@"http://api.wedfairy.com/api/users/wechat-auth/?code=%@&state=hybrid|ios", resp.code] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
        [WedfairyUserDefaults standardUserDefaults].back_from_wechat_login = YES;
    }
    else if(resp.errCode == -2){
        [WedfairyUserDefaults standardUserDefaults].user_cancelled = YES;
        [WedfairyUserDefaults standardUserDefaults].wechat_auth_url = @"http://compose.wedfairy.com/";
    }
}



@end
