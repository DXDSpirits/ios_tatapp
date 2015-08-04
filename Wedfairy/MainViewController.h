//
//  ViewController.h
//  Wedfairy
//
//  Created by Fei Wen on 7/9/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@import WebKit;

@interface MainViewController : UIViewController<WXApiDelegate>

-(void)loadNewPage : (NSURL *)url;
-(NSURL *)fetchCurrentPage;

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

- (IBAction)refreshBtnPressed:(id)sender;

@end

