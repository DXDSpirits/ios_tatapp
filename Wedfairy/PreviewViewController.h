//
//  PreviewViewController.h
//  Wedfairy
//
//  Created by Fei Wen on 7/19/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface PreviewViewController : UIViewController

@property (strong, nonatomic) NSString *preview_url;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;

- (IBAction)refreshBtnPressed:(id)sender;


@end
