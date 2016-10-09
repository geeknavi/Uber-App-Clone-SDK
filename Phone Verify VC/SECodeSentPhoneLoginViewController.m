//
//  SECodeSentPhoneLoginViewController.m
//  GeekNavi
//
//  Created by GeekNavi on 2/17/15.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "SECodeSentPhoneLoginViewController.h"
#import "Constant.h"
#import "AppDelegate.h"

@interface SECodeSentPhoneLoginViewController (){
    
    __weak IBOutlet UILabel *verifyLabel;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UITextField *vericiationCodeTextField;
    __weak IBOutlet UILabel *codeSentToLabel;
    __weak IBOutlet UIButton *resendbutton;
    __weak IBOutlet UIButton *verifybtn;
    
    int verificationCode;
}

@end

@implementation SECodeSentPhoneLoginViewController

@synthesize userphone,userRegister,vFirst,vLast,vEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customizeLabelsAndButtons];
    [self customizeTextField];
    [self sendVerificationCode];
}

#pragma mark - Theme Customizations
-(void)customizeLabelsAndButtons{
    verifybtn.layer.cornerRadius = 5;
    verifybtn.layer.masksToBounds = YES;
    
    [verifybtn setBackgroundColor:THEME_COLOR];
    [verifyLabel setTextColor:THEME_COLOR];
    [backBtn setTitleColor:THEME_COLOR forState:UIControlStateNormal];
}

#pragma mark - Customizes Text Field
-(void)customizeTextField{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignFirstResponder)],
                           nil];
    [numberToolbar sizeToFit];
    
    vericiationCodeTextField.inputAccessoryView = numberToolbar;
    vericiationCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    vericiationCodeTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"telephone.png"]];
    vericiationCodeTextField.layer.borderWidth = 1.0f;
    vericiationCodeTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    vericiationCodeTextField.layer.cornerRadius = 5.0f;
    [vericiationCodeTextField becomeFirstResponder];
}

#pragma mark - Creates new user
-(void)createNewUser{
    NSDictionary *param = @{@"vFirst"
                            :[vFirst stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                            @"vLast":[vLast stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                            @"vEmail":vEmail,
                            @"userPhone":userphone
                            };
    
    [GeekNavi registerUserWithParameters:param image:nil block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult == WebServiceResultSuccess) {
            removeLoading();
            AppDelegate *dlg = [[AppDelegate alloc] init];
            [dlg initializeMainRootViewController];
        }
    }];
}

#pragma mark - Logs in existing user
-(void)loginExistingUserWithEmail:(NSString *)email{
    [self.view endEditing:YES];
    addLoading(NSLocalizedString(@"logging_in", nil));
    
    [GeekNavi loginUserWithEmail:email block:^(id JSON, WebServiceResult geekResult) {
        if(geekResult==WebServiceResultSuccess){
            removeLoading();
            AppDelegate *dlg = [[AppDelegate alloc] init];
            [dlg initializeMainRootViewController];
        }
    }];
}

#pragma mark - Send verification code
-(void)sendVerificationCode{
    codeSentToLabel.text = [NSString stringWithFormat:@"%@ +%@",NSLocalizedString(@"code_sent_to", nil), userphone];
    
    [GeekNavi sendTextMessageToPhoneNumber:userphone block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            verificationCode = [JSON[@"message"] intValue];
        }else{
            showAlertViewWithMessage(NSLocalizedString(@"error_text_message", nil));
        }
    }];
}

#pragma mark - Decipher Phone number
-(void)decipherPhoneNumber{
    [GeekNavi loginwithPhone:userphone block:^(id JSON, WebServiceResult geekResult) {
        if ([JSON[@"message"]isEqualToString:@"No user registered!"]){
            if (userRegister == YES) {
                addLoading(NSLocalizedString(@"signing_up", nil));
                [self.view endEditing:YES];
                [self createNewUser];
            }else{
                showAlertViewWithMessage(NSLocalizedString(@"no_account", nil));
            }
        }else if ([JSON[@"status"]isEqualToString:@"0"]){
            [self loginExistingUserWithEmail:JSON[@"message"]];
        }
    }];
}
#pragma mark - IBActions
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)verifyTextMessageAction:(id)sender {
    if ([vericiationCodeTextField.text intValue] == verificationCode) {
        [self decipherPhoneNumber];
    }else{
        showAlertViewWithMessage(NSLocalizedString(@"incorrect_verification_code", nil));
    }
}
- (IBAction)resendAction:(id)sender {
    static dispatch_once_t resendToken;
    dispatch_once(&resendToken, ^{
        [self sendVerificationCode];
    });
}

@end
