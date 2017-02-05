//
//  LoginViewController.m
//
//  Created By GeekNavi on 07/02/14.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "Constant.h"
#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController (){
    // UIViews
    __weak IBOutlet UIView *logins;
    
    // UIButtons
    __weak IBOutlet UIButton *signUpButton;
    __weak IBOutlet UIButton *loginButton;
}

@end

@implementation LoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self customizeThemeAndButtons];
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    if ([FBSDKAccessToken currentAccessToken]) {
        [self autoLoginFacebook];
    }else if ([GeekNavi geekHasAccessToken]) {
        [self autoLoginPhoneNumber:nil];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [logins setHidden:NO];
}

#pragma mark - Phone Number Auto Login Method
-(void)autoLoginPhoneNumber:(NSString *)storedEmail{
    [logins setHidden:YES];
    
    [GeekNavi loginUserWithEmail:storedEmail block:^(id JSON, WebServiceResult geekResult) {
        if(geekResult==WebServiceResultSuccess){
            AppDelegate *dlg = [[AppDelegate alloc] init];
            [dlg initializeMainRootViewController];
        }else{
            [logins setHidden:NO];
            showAlertViewWithTitleAndMessage(nil,JSON[@"message"]);
        }
    }];
}

#pragma mark - Facebook Auto Login Method
-(void)autoLoginFacebook{
    [logins setHidden:YES];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             if(result){
                 [GeekNavi loginUserWithFacebook:result[@"id"] block:^(id JSON, WebServiceResult geekResult) {
                     if(geekResult==WebServiceResultSuccess && [JSON[@"data"] count] != 0){
                         AppDelegate *dlg = [[AppDelegate alloc] init];
                         [dlg initializeMainRootViewController];
                     }else{
                         showAlertViewWithTitleAndMessage(nil,JSON[@"message"]);
                         [logins setHidden:NO];
                     }
                 }];
             }
             else{
                 showAlertViewWithTitleAndMessage(nil,error.localizedDescription);
                 [logins setHidden:NO];
             }
         }else{
             showAlertViewWithTitleAndMessage(nil,error.localizedDescription);
             [logins setHidden:NO];
         }
     }];
}

#pragma mark - Customize Screen & Buttons
-(void)customizeThemeAndButtons{
    [self.view setBackgroundColor:MAIN_THEME_COLOR];
    [loginButton setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
    
    loginButton.layer.borderWidth = 2.0f;
    loginButton.layer.borderColor = loginButton.titleLabel.textColor.CGColor;
    loginButton.layer.cornerRadius = 5;
    loginButton.layer.masksToBounds = YES;
    
    signUpButton.layer.cornerRadius = 5;
    signUpButton.layer.masksToBounds = YES;
    [signUpButton setBackgroundColor:SUB_THEME_COLOR];
    [signUpButton setTitleColor:MAIN_THEME_COLOR forState:UIControlStateNormal];
}

@end
