//
//  SETermsAndCondiViewController.m
//  GeekNavi
//
//  Created by GeekNavi on 21/08/14.
//  Copyright (c) 2014 GeekNavi. All rights reserved.
//

#import "SETermsAndCondiViewController.h"
#import "Constant.h"
#import "AppDelegate.h"

@interface SETermsAndCondiViewController (){
    // UIViews
    __weak IBOutlet UIView *topnavi;
    
    // Labels
    __weak IBOutlet UILabel *termsLabel;
    
    // Buttons
    __weak IBOutlet UIButton *btnAgree;
    __weak IBOutlet UIButton *backButton;
}
@end

@implementation SETermsAndCondiViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // As always, start with customizing the screen (MAIN/SUB Colors)
    [self customizeScreen];
    
    btnAgree.hidden = !self.isAgree;
}

#pragma mark - Agree Action
- (IBAction)onAgree:(id)sender {
    addLoading(@"");
    [GeekNavi registerUserWithParameters:self.param image:self.img block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess){
            removeLoading();
            AppDelegate *dlg = [[AppDelegate alloc] init];
            [dlg initializeMainRootViewController];
        }
    }];
}

#pragma mark - Back Action
- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Customize screen
-(void)customizeScreen{
    [self.view setBackgroundColor:MAIN_THEME_COLOR];
    [topnavi setBackgroundColor:MAIN_THEME_COLOR];
    
    [btnAgree setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
    [backButton setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
    
    [termsLabel setTextColor:SUB_THEME_COLOR];
}

@end
