//
//  ViewController.m
//  Wedfairy
//
//  Created by Fei Wen on 7/9/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import <SIAlertView/SIAlertView.h>
#import <Bolts/Bolts.h>

#import "WedfairyUserDefaults.h"
#import "MainViewController.h"
#import "UMSocial.h"
#import "PreviewViewController.h"

NSString * const MESSAGE_HANDLER = @"previewStory";
NSString * const WECHAT_MESSAGE = @"wechatLogin";

@interface MainViewController ()<WKNavigationDelegate, WKScriptMessageHandler, UMSocialUIDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *wedfairy_webview;
@property (atomic) BOOL viewSizeChanged;
@property (nonatomic, strong) NSURL *wechat_auth_url;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    WKWebViewConfiguration *mainWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
    
    NSString *adjustNavJS = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Adjust_Navbar" withExtension:@"js"]
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    
    
    WKUserScript *adjustNavScript = [[WKUserScript alloc] initWithSource:adjustNavJS
                                                         injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                      forMainFrameOnly:NO];
    
    [mainWebViewConfiguration.userContentController addUserScript:adjustNavScript];
    [mainWebViewConfiguration.userContentController addScriptMessageHandler:self name:MESSAGE_HANDLER];
    [mainWebViewConfiguration.userContentController addScriptMessageHandler:self name:WECHAT_MESSAGE];
    
    _wedfairy_webview = [[WKWebView alloc]initWithFrame:CGRectZero configuration:mainWebViewConfiguration];
    _wedfairy_webview.scrollView.bounces = NO;
    _wedfairy_webview.UIDelegate = self;
    
    [self.view addSubview:_wedfairy_webview];
    
    // Constraints
    [_wedfairy_webview setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_wedfairy_webview
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    [self.view addConstraint:widthConstraint];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_wedfairy_webview
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:0];
    [self.view addConstraint:heightConstraint];
    
    NSURL *url = [NSURL URLWithString:@"http://compose.wedfairy.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_wedfairy_webview loadRequest:request];
    
    self.viewSizeChanged = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (!self.viewSizeChanged) {
        CGRect viewBounds = [self.wedfairy_webview bounds];
        viewBounds.origin.y = 20;
        viewBounds.size.height = viewBounds.size.height - 20;
        self.wedfairy_webview.frame = viewBounds;
        self.viewSizeChanged = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    
    if(![WedfairyUserDefaults standardUserDefaults].wechat_auth_url){
        NSURL *url = [NSURL URLWithString:[WedfairyUserDefaults standardUserDefaults].wechat_auth_url];
        NSURLRequest *wechat_request = [NSURLRequest requestWithURL:url];
        [_wedfairy_webview loadRequest:wechat_request];
        [WedfairyUserDefaults standardUserDefaults].wechat_auth_url = nil;
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

 
- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message {
    if([message.name isEqualToString:MESSAGE_HANDLER]) {
        // The message.body contains the object being posted back
        NSLog(@"Message received.");
        NSDictionary *story_dict = message.body;
        PreviewViewController *pVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PreviewViewController"];
        pVC.preview_url = [story_dict objectForKey:@"storyUrl"];
        [self.navigationController pushViewController:pVC animated:YES];
    }
    else if ([message.name isEqualToString:WECHAT_MESSAGE]){
        NSDictionary *msg_dict = message.body;
        NSString *state = [msg_dict objectForKey:@"state"];
    
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = state;
        [WXApi sendReq:req];
    }
    else{
        NSLog(@"Other messages");
    }
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"错误" andMessage:message];
    [alertView addButtonWithTitle:@"好的"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              completionHandler();
                          }];
    
    [alertView show];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"确认？" andMessage:message];
    
    [alertView addButtonWithTitle:@"好的"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              completionHandler(YES);
                          }];
    
    [alertView addButtonWithTitle:@"再想想"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              completionHandler(NO);
                          }];

    [alertView show];
}


-(void)loadNewPage : (NSURL *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_wedfairy_webview loadRequest:request];
}

@end
