//
//  RegisterViewController.m
//
//
//  Created By GeekNavi on 07/02/14.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "RegisterViewController.h"
#import "SEAddPhoneNumberVC.h"
#import "SETermsAndCondiViewController.h"
#import "AppDelegate.h"

@interface RegisterViewController ()
{
    __weak IBOutlet UITextField    *txtFirstName;
    __weak IBOutlet UITextField    *txtLastName;
    __weak IBOutlet UITextField    *txtEmail;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIButton *nextBtn;
    __weak IBOutlet FBSDKLoginButton *signUpFacebookBtn;
    
    NSDictionary *parameters;
    UIImage *profileImage;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self themeAndTextFieldCustomizations];
    
    signUpFacebookBtn.readPermissions =
    @[@"public_profile", @"email"];
}

#pragma mark - Theme And Text Field Customizations
-(void)themeAndTextFieldCustomizations{
    [backBtn setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [titleLabel setTextColor:THEME_COLOR];
    [nextBtn setBackgroundColor:THEME_COLOR];
    
    txtFirstName.leftViewMode = UITextFieldViewModeAlways;
    txtFirstName.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userIcon.png"]];
    txtFirstName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtFirstName.layer.borderWidth = 1.0f;
    txtFirstName.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    txtFirstName.layer.cornerRadius = 5.0f;
    
    txtLastName.leftViewMode = UITextFieldViewModeAlways;
    txtLastName.autocorrectionType = UITextAutocorrectionTypeNo;
    txtLastName.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userIcon.png"]];
    txtLastName.layer.borderWidth = 1.0f;
    txtLastName.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    txtLastName.layer.cornerRadius = 5.0f;
    
    txtEmail.leftViewMode = UITextFieldViewModeAlways;
    txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    txtEmail.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emailIcon.png"]];
    txtEmail.layer.borderWidth = 1.0f;
    txtEmail.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    txtEmail.layer.cornerRadius = 5.0f;
    
    nextBtn.layer.cornerRadius = 5;
    nextBtn.layer.masksToBounds = YES;
    
    [signUpFacebookBtn.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20]];
    
    [txtFirstName becomeFirstResponder];
}

#pragma mark - Facebook login button did complete
-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    if (error) {
        // Process error
        NSLog(@"%@",error.description);
    } else if (result.isCancelled) {
        // Handle cancellations
        NSLog(@"Result Cancelled!");
    } else {
        // If you ask for multiple permissions at once, you
        // should check if specific permissions missing
        
        if ([result.grantedPermissions containsObject:@"email"]) {
            // Do work
            [self facebookLoginMethod];
        }
    }
}

#pragma mark - Facebook Login Method
-(void)facebookLoginMethod{
    [self.view endEditing:YES];

    addLoading(NSLocalizedString(@"signing_up", nil));
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,first_name,last_name,name,email,picture.height(180).width(180)"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             if(result){
                 NSDictionary *tmpDict = [result copy];
                 
                 removeLoading();
                 
                 [GeekNavi loginUserWithFacebook:tmpDict[@"id"] block:^(id JSON, WebServiceResult geekResult) {
                     if (geekResult==WebServiceResultSuccess){
                         AppDelegate *dlg = [[AppDelegate alloc] init];
                         [dlg initializeMainRootViewController];
                     }else if(geekResult==WebServiceResultFail){
                         if([JSON[@"status"] isEqualToString:@"2"]){ // Sign up user
                             [self registerUserWithDictionary:[tmpDict copy]];
                         }
                     }
                 }];
             }
         }else{
             showAlertViewWithMessage(error.localizedDescription);
             NSLog(@"%@",error.localizedDescription);
         }
     }];
}

#pragma mark - Register User with Response from Facebook
-(void)registerUserWithDictionary:(NSDictionary *)dict{
    parameters = @{@"vFirst":dict[@"first_name"],
                   @"vLast":dict[@"last_name"],
                   @"vEmail":dict[@"email"],
                   @"vFbID":dict[@"id"]};
    removeLoading();
    [self performSegueWithIdentifier:@"agreeSegue" sender:self];
}

#pragma mark - TextField Should Return
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(txtFirstName==textField){
        [txtLastName becomeFirstResponder];
    }else if (txtLastName==textField){
        [txtEmail becomeFirstResponder];
    }else if (txtEmail==textField){
        [txtEmail resignFirstResponder];
        [self nextAction:self];
    }
    return YES;
}

#pragma mark -Button IBAction
- (IBAction)nextAction:(id)sender {
    if (![self checkUserInput]) {
        return;
    }else{
    [self performSegueWithIdentifier:@"addPhonenumber" sender:self];
    }
}
- (IBAction)backButton:(id)sender {
    NSLog(@"back");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Check User's Input
-(BOOL)checkUserInput{
    if(![NSStringWithoutSpace(txtFirstName.text) length]){
        [txtFirstName becomeFirstResponder];
        return NO;
    }else if(![NSStringWithoutSpace(txtLastName.text) length]){
        [txtLastName becomeFirstResponder];
        return NO;
    }else if (!validateEmail(txtEmail.text)){
        showAlertViewWithMessage(NSLocalizedString(@"email_invalid", nil));
        [txtEmail becomeFirstResponder];
        return NO;
    }
    else{
        return YES;
    }
}

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"addPhonenumber"]){
        SEAddPhoneNumberVC *vc=(SEAddPhoneNumberVC *)segue.destinationViewController;
        vc.vFirst = txtFirstName.text;
        vc.vLast = txtLastName.text;
        vc.vEmail = txtEmail.text;
    }else if([[segue identifier] isEqualToString:@"agreeSegue"]){
        SETermsAndCondiViewController *vc=(SETermsAndCondiViewController *)segue.destinationViewController;
        vc.param=parameters;
        vc.img=profileImage;
        vc.isAgree=YES;
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{} // Only here to surpress warnings
@end
