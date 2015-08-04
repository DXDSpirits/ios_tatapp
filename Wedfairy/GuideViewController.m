//
//  GuideViewController.m
//  Wedfairy
//
//  Created by Fei Wen on 8/3/15.
//  Copyright (c) 2015 Sbx. All rights reserved.
//

#import "GuideViewController.h"
#import <EAIntroView.h>
#import "DeviceDetector.h"

@interface GuideViewController ()<EAIntroDelegate>

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showGuide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"lastViewController", nil]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showGuide{
        
    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:@"guide-1"];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"guide-2"];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:@"guide-3"];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.bgImage = [UIImage imageNamed:@"guide-4"];
    
    EAIntroPage *page5 = [EAIntroPage page];
    page5.bgImage = [UIImage imageNamed:@"guide-5"];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2, page3, page4, page5]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.3];
    
    //intro.pageControlY = self.view.frame.size.height - 55;
    intro.pageControlY = self.view.frame.size.height - 50;
    
    if([[DeviceDetector platformString] isEqualToString:@"iPhone 6 Plus"] || [[DeviceDetector platformString] isEqualToString:@"iPhone 6"]){
        intro.pageControlY = self.view.frame.size.height - 55;
        intro.skipButtonY = self.view.frame.size.height - 55;
    }
    else if([[DeviceDetector platformString] isEqualToString:@"iPhone 5"] || [[DeviceDetector platformString] isEqualToString:@"iPhone 5s"]){
        intro.pageControlY = self.view.frame.size.height - 50;
        intro.skipButtonY = self.view.frame.size.height - 50;
    }
    else{
        intro.pageControl.hidden = YES;
    }
    
    intro.pageControl.userInteractionEnabled = NO;
    [intro.skipButton setTitle:@"跳过" forState:UIControlStateNormal];
    
}


#pragma mark - EAIntroView delegate

- (void)introDidFinish:(EAIntroView *)introView {
    NSLog(@"introDidFinish callback");
 
    [self performSegueWithIdentifier:@"guideFinishSegue" sender:self];
}



@end
