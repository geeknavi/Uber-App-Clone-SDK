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
    __weak IBOutlet UIButton *loginWithPhoneBtn;
    __weak IBOutlet UIButton *loginWithFacebookButton;
    __weak IBOutlet UIView *logins;
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
    [logins setHidden:NO];
}

-(void)customizeThemeAndButtons{
    [self.view setBackgroundColor:THEME_COLOR];
    [loginWithPhoneBtn setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    
    loginWithFacebookButton.layer.borderWidth = 2.0f;
    loginWithFacebookButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    loginWithFacebookButton.layer.cornerRadius = 5;
    loginWithFacebookButton.layer.masksToBounds = YES;
    
    loginWithPhoneBtn.layer.cornerRadius = 5;
    loginWithPhoneBtn.layer.masksToBounds = YES;
}

#pragma mark - Auto Login User Methods
-(void)autoLoginPhoneNumber:(NSString *)storedEmail{
    [logins setHidden:YES];
    
    [GeekNavi loginUserWithEmail:storedEmail block:^(id JSON, WebServiceResult geekResult) {
        if(geekResult==WebServiceResultSuccess){
            AppDelegate *dlg = [[AppDelegate alloc] init];
            [dlg initializeMainRootViewController];
        }else{
            [logins setHidden:NO];
            showAlertViewWithMessage(JSON[@"message"]);
        }
    }];
}

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
                         showAlertViewWithMessage(JSON[@"message"]);
                         [logins setHidden:NO];
                     }
                 }];
             }
             else{
                 showAlertViewWithMessage(error.localizedDescription);
                 [logins setHidden:NO];
             }
         }else{
             showAlertViewWithMessage(error.localizedDescription);
             [logins setHidden:NO];
         }
     }];
}

@end
