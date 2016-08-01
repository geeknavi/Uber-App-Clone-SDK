//
//  SETermsAndCondiViewController.m
//  Social_Events
//
//  Created by iOSDeveloper4 on 21/08/14.
//  Copyright (c) 2014 Social_Events. All rights reserved.
//

#import "SETermsAndCondiViewController.h"
#import "Constant.h"
#import "AppDelegate.h"

@interface SETermsAndCondiViewController (){
    __weak IBOutlet UIView *topnavi;
    __weak IBOutlet UIButton *btnAgree;
}
@end

@implementation SETermsAndCondiViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [topnavi setBackgroundColor:THEME_COLOR];
    
    btnAgree.hidden=!self.isAgree;
}
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
- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
