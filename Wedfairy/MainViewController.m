//
//  ViewController.m
//  Wedfairy
//
//  Created by Fei Wen on 7/9/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import <SIAlertView/SIAlertView.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>


#import "WedfairyUserDefaults.h"
#import "MainViewController.h"
#import "UMSocial.h"
#import "PreviewViewController.h"

NSString * const MESSAGE_HANDLER = @"previewStory";
NSString * const WECHAT_MESSAGE = @"wechatLogin";
NSString * const WEBAPP_READY = @"webappReady";

@interface MainViewController ()<WKNavigationDelegate, WKScriptMessageHandler, UMSocialUIDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *wedfairy_webview;
@property (atomic) BOOL viewSizeChanged;
@property (nonatomic, strong) NSURL *wechat_auth_url;
@property (nonatomic, strong) NSDate *start_loading_time;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self setupWebVew];
    [self setupLoadingView];
    
    _loadingView.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [WedfairyUserDefaults standardUserDefaults].first_time_use = NO;
    
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
        [WedfairyUserDefaults standardUserDefaults].will_go_wechat_login = YES;
        [WXApi sendReq:req];
    }
    else if ([message.name isEqualToString:WEBAPP_READY]){
        
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

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"loading"]) {
        
        NSDate *current_time = [NSDate date];
        NSTimeInterval since = [current_time timeIntervalSinceDate: _start_loading_time];
        if (since >= 10) {
            _loadingView.hidden = NO;
        }
        
        if (!_wedfairy_webview.loading) {
            [self.progressBar setProgress:0.0f animated:NO];
        }
        
    }else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        self.progressBar.hidden = _wedfairy_webview.estimatedProgress == 1;
        self.progressBar.progress = _wedfairy_webview.estimatedProgress;
        
    }else if ([keyPath isEqualToString:@"URL"]) {
        _start_loading_time = [NSDate date];
        [self.progressBar setProgress:0.0f animated:NO];
        
    }
}


-(void)loadNewPage : (NSURL *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_wedfairy_webview loadRequest:request];
}

-(NSURL *)fetchCurrentPage{
    return _wedfairy_webview.URL;
}


- (IBAction)refreshBtnPressed:(id)sender {

    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        _loadingView.hidden = YES;
        _start_loading_time = [NSDate date];
        
        [self.progressBar setProgress:0.0f animated:NO];
        if (_wedfairy_webview.URL) {
            [_wedfairy_webview loadRequest:[NSURLRequest requestWithURL:_wedfairy_webview.URL]];
        }
        else{
            NSURL *url = [NSURL URLWithString:@"http://compose.wedfairy.com"];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [_wedfairy_webview loadRequest:request];
        }
    }
    
}

- (void)setupLoadingView{
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        if (_wedfairy_webview.loading && status == AFNetworkReachabilityStatusNotReachable) {
            _loadingView.hidden = NO;
            [self.progressBar setProgress:0.0f animated:NO];
        }
        else if(_loadingView.hidden == NO && (status == AFNetworkReachabilityStatusReachableViaWWAN && status == AFNetworkReachabilityStatusReachableViaWiFi)){
            _loadingView.hidden = YES;
            [self.progressBar setProgress:0.0f animated:NO];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)setupWebVew{
    
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
    [mainWebViewConfiguration.userContentController addScriptMessageHandler:self name:WEBAPP_READY];
    
    _wedfairy_webview = [[WKWebView alloc]initWithFrame:CGRectZero configuration:mainWebViewConfiguration];
    _wedfairy_webview.scrollView.bounces = NO;
    _wedfairy_webview.UIDelegate = self;
    
    [_wedfairy_webview addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [_wedfairy_webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [_wedfairy_webview addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    
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

}


@end
