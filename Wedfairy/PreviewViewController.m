//
//  PreviewViewController.m
//  Wedfairy
//
//  Created by Fei Wen on 7/19/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import "PreviewViewController.h"
#import "UMSocial.h"

@interface PreviewViewController ()<WKNavigationDelegate, WKScriptMessageHandler, UMSocialUIDelegate>
@property (nonatomic, strong) WKWebView *wedfairy_webview;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    WKWebViewConfiguration *mainWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
    [mainWebViewConfiguration.userContentController addScriptMessageHandler:self name:@"shareStory"];
    
    _wedfairy_webview = [[WKWebView alloc]initWithFrame:CGRectZero configuration:mainWebViewConfiguration];
    _wedfairy_webview.scrollView.bounces = NO;
    
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

-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    NSURL *url = [NSURL URLWithString:_preview_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_wedfairy_webview loadRequest:request];

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
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:@"55ab622967e58e5411005fde"
                                          shareText:[story_dict objectForKey:@"description"]
                                         shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[story_dict objectForKey:@"img_url"]]]]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,UMShareToWechatSession,UMShareToWechatTimeline, nil]
                                           delegate:self];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
