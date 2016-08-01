//
//  SEPhoneLoginViewController.m
//  GeekNavi
//
//  Created by GeekNavi on 2/17/15.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "SEPhoneLoginViewController.h"
#import "SECodeSentPhoneLoginViewController.h"
#import "SETermsAndCondiViewController.h"
#import "AppDelegate.h"

@interface SEPhoneLoginViewController (){
    __weak IBOutlet FBSDKLoginButton *loginButton;
    __weak IBOutlet GeekNaviCountryPicker *geekCountryPicker;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *loginLabel;
    __weak IBOutlet UIButton *setCountryBtn;
    __weak IBOutlet UITextField *phoneNumberTextField;
    __weak IBOutlet UIButton *nextbutton;
    
    UIImage *profileImage;
    NSDictionary *parameters;
    
    NSString *countryCode;
    NSString *numberCode;
    
    UIButton *countryButton;
}
@end

@implementation SEPhoneLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeButtonsAndLabels];
    [self customizeTextFieldAndAddButton];
    
    loginButton.readPermissions =
    @[@"public_profile", @"email"];
}

#pragma mark - Customizing Theme color and corner radius
-(void)customizeButtonsAndLabels{
    nextbutton.layer.cornerRadius = 5;
    nextbutton.layer.masksToBounds = YES;
    setCountryBtn.layer.cornerRadius = 5;
    setCountryBtn.layer.masksToBounds = YES;
    
    [nextbutton setBackgroundColor:THEME_COLOR];
    [loginLabel setTextColor:THEME_COLOR];
    [backBtn setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [setCountryBtn setBackgroundColor:THEME_COLOR];
    
    [loginButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20]];
}

#pragma mark - Adding Country Picker to Textfield
-(void)customizeTextFieldAndAddButton{
    phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
    phoneNumberTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"telephone.png"]];
    phoneNumberTextField.layer.borderWidth = 1.0f;
    phoneNumberTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    phoneNumberTextField.layer.cornerRadius = 5.0f;
    [phoneNumberTextField becomeFirstResponder];
    
    countryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    countryButton.frame = CGRectMake(0, 0, 20, 20);
    countryButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    [countryButton addTarget:self action:@selector(changeCountry) forControlEvents:UIControlEventTouchUpInside];
    phoneNumberTextField.rightView = countryButton;
    phoneNumberTextField.rightViewMode = UITextFieldViewModeAlways;
    
    numberCode = [GeekNaviCountryPicker getCountryCode:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
    [GeekNaviCountryPicker changeFlagDependingOnCode:nil returnImage:^(UIImage *image) {
        if (image) {
            [countryButton setImage:image forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - Change Country Action when button is tapped
-(void)changeCountry{
    [geekCountryPicker setHidden:NO];
    [nextbutton setHidden:YES];
    [phoneNumberTextField setHidden:YES];
    [setCountryBtn setHidden:NO];
    [self.view endEditing:YES];
}

#pragma mark - Delegate Action when picker did select
-(void)GeekNaviCountryPicker:(GeekNaviCountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code{
    countryCode = code;
    numberCode = [GeekNaviCountryPicker getCountryCode:code];
}

#pragma mark - Facebook login button did complete
-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
        if (error) {
            // Process error
            NSLog(@"%@",error.description);
        } else if (result.isCancelled) {
            // Handle cancellations
            NSLog(@"Cancelled!");
        } else {
            if ([result.grantedPermissions containsObject:@"email"]) {
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
                         if([JSON[@"status"] isEqualToString:@"2"]){
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

#pragma mark - IBActions
- (IBAction)nextButtonAction:(id)sender {
    [GeekNavi loginwithPhone:[NSString stringWithFormat:@"%@%@",numberCode,phoneNumberTextField.text] block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            if ([JSON[@"message"]isEqualToString:@"No user registered!"]){
                showAlertViewWithMessage(NSLocalizedString(@"no_account", nil));
                phoneNumberTextField.layer.borderColor = [[UIColor redColor]CGColor];
            }else if ([JSON[@"status"]isEqualToString:@"0"]){
                [self performSegueWithIdentifier:@"pushtoCode" sender:self];
            }
        }
    }];
}
- (IBAction)setCountry:(id)sender {
    [setCountryBtn setHidden:YES];
    [geekCountryPicker setHidden:YES];
    [nextbutton setHidden:NO];
    [phoneNumberTextField setHidden:NO];
    [phoneNumberTextField becomeFirstResponder];
    
    [GeekNaviCountryPicker changeFlagDependingOnCode:countryCode returnImage:^(UIImage *image) {
        if (image) {
            [countryButton setImage:image forState:UIControlStateNormal];
        }
    }];
}
- (IBAction)backButton:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Prepare for Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"pushtoCode"]) {
        SECodeSentPhoneLoginViewController *vc = (SECodeSentPhoneLoginViewController *)[segue destinationViewController];
        vc.userphone = [NSString stringWithFormat:@"%@%@",numberCode,phoneNumberTextField.text];
    }else if([[segue identifier] isEqualToString:@"agreeSegue"]){
        SETermsAndCondiViewController *vc=(SETermsAndCondiViewController *)segue.destinationViewController;
        vc.param=parameters;
        vc.img=profileImage;
        vc.isAgree=YES;
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{} // Only here to surpress warning
@end
