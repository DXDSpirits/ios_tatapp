//
//  PreviewViewController.m
//  Wedfairy
//
//  Created by Fei Wen on 7/19/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import "PreviewViewController.h"
#import "UMSocial.h"

#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface PreviewViewController ()<WKNavigationDelegate, WKScriptMessageHandler, UMSocialUIDelegate>

@property (nonatomic, strong) WKWebView *wedfairy_webview;
@property (nonatomic, strong) NSDate *start_loading_time;
@property (atomic) BOOL viewSizeChanged;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:241/255.0f green:95/255.0f blue:92/255.0f alpha:1.0];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, 320, 44)];
    
    [self setupWebVew];
    [self setupLoadingView];

}

-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    NSURL *url = [NSURL URLWithString:_preview_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_wedfairy_webview loadRequest:request];

    if (!self.viewSizeChanged) {
        CGRect viewBounds = [self.wedfairy_webview bounds];
        viewBounds.origin.y = 20;
        viewBounds.size.height = viewBounds.size.height - 20;
        self.wedfairy_webview.frame = viewBounds;
        self.viewSizeChanged = YES;
    }

}

-(void)viewDidDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    NSURL *url = [NSURL URLWithString:@"about:blank"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_wedfairy_webview loadRequest:request];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message {
    
    if([message.name isEqualToString:@"shareStory"]){

        NSDictionary *story_dict = message.body;
        //NSLog(@"share body = %@", message.body);
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"55ab622967e58e5411005fde"
                                          shareText:[story_dict objectForKey:@"description"]
                                         shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[story_dict objectForKey:@"img_url"]]]]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToRenren,UMShareToWechatSession,UMShareToWechatTimeline, nil]
                                           delegate:self];
        
        [UMSocialData defaultData].extConfig.wechatSessionData.title = [story_dict objectForKey:@"title"];
        [UMSocialData defaultData].extConfig.wechatTimelineData.title = [story_dict objectForKey:@"title"];
        
        [UMSocialData defaultData].extConfig.wechatSessionData.url = [story_dict objectForKey:@"link"];
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = [story_dict objectForKey:@"link"];

        
    }
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)refreshBtnPressed:(id)sender {
    
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        _loadingView.hidden = YES;
        _start_loading_time = [NSDate date];
        
        [self.progressBar setProgress:0.0f animated:NO];
        if (_wedfairy_webview.URL) {
            [_wedfairy_webview loadRequest:[NSURLRequest requestWithURL:_wedfairy_webview.URL]];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
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
            [_wedfairy_webview loadRequest:[NSURLRequest requestWithURL:_wedfairy_webview.URL]];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    _loadingView.hidden = YES;
}

- (void)setupWebVew{
    WKWebViewConfiguration *mainWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
    
    [mainWebViewConfiguration.userContentController addScriptMessageHandler:self name:@"shareStory"];
    
    _wedfairy_webview = [[WKWebView alloc]initWithFrame:CGRectZero configuration:mainWebViewConfiguration];
    _wedfairy_webview.scrollView.bounces = NO;
    
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


@end
