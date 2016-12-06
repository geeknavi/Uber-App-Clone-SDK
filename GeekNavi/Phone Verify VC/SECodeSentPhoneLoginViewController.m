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

@interface SECodeSentPhoneLoginViewController () <UITextFieldDelegate>{
    // UIButtons
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UIButton *resendbutton;
    __weak IBOutlet UIButton *verifybtn;
    
    // UILabels
    __weak IBOutlet UILabel *codeSentToLabel;
    __weak IBOutlet UILabel *verifyLabel;
    
    // UITextFields
    __weak IBOutlet UITextField *vericiationCodeTextField;
    
    // Constraints
    __weak IBOutlet NSLayoutConstraint *verifyButtonBottomConstraint;
    
    // Instance variables
    int verificationCode;
}

@end

@implementation SECodeSentPhoneLoginViewController
@synthesize userphone,userRegister,vFirst,vLast,vEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // As always, start with customizing the screen
    [self customizeLabelsAndButtons];

    // Then, send a verification code to whatever phone number was entered on the previous screen
    [self sendVerificationCode];
    
    // Sign up for keyboard notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Bring up keyboard
    [vericiationCodeTextField becomeFirstResponder];
}
#pragma mark - Go Back Action
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Verify Text Message Action
- (IBAction)verifyTextMessageAction:(id)sender {
    addLoading(@"");
    if ([vericiationCodeTextField.text intValue] == verificationCode) {
        [self decipherPhoneNumber];
    }else{
        showAlertViewWithTitleAndMessage(nil,NSLocalizedString(@"incorrect_verification_code", nil));
    }
}

#pragma mark - Resend Text Message Action
- (IBAction)resendAction:(id)sender {
    static dispatch_once_t resendToken;
    dispatch_once(&resendToken, ^{
        [self sendVerificationCode];
    });
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
            showAlertViewWithTitleAndMessage(nil,NSLocalizedString(@"error_text_message", nil));
        }
    }];
}

#pragma mark - Decipher Phone number
-(void)decipherPhoneNumber{
    [GeekNavi loginwithPhone:userphone block:^(id JSON, WebServiceResult geekResult) {
        removeLoading();
        if ([JSON[@"message"]isEqualToString:@"No user registered!"]){
            if (userRegister == YES) {
                addLoading(NSLocalizedString(@"signing_up", nil));
                [self.view endEditing:YES];
                [self createNewUser];
            }else{
                showAlertViewWithTitleAndMessage(nil,NSLocalizedString(@"no_account", nil));
            }
        }else if ([JSON[@"status"]isEqualToString:@"0"]){
            [self loginExistingUserWithEmail:JSON[@"message"]];
        }
    }];
}

#pragma mark - Text Field Delegates
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length){
        return NO;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textField.text];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(13.0f)
                             range:NSMakeRange(0, textField.text.length)];
    textField.attributedText = attributedString;
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength == 4){
        // Next
        textField.text = [textField.text stringByAppendingString:string];
        [self verifyTextMessageAction:nil];
        return NO;
    }
    
    return newLength <= 4;
}

#pragma mark - Theme Customizations
-(void)customizeLabelsAndButtons{
    [self.view setBackgroundColor:MAIN_THEME_COLOR];
    
    [verifybtn setBackgroundColor:SUB_THEME_COLOR];
    [verifyLabel setTextColor:SUB_THEME_COLOR];
    [backBtn setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
    
    resendbutton.layer.cornerRadius = 5.0f;
    resendbutton.layer.masksToBounds = YES;
    resendbutton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    resendbutton.layer.borderWidth = 1.0f;
    
    // Add spacing to UITextField
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [vericiationCodeTextField setLeftViewMode:UITextFieldViewModeAlways];
    [vericiationCodeTextField setLeftView:spacerView];
}

#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(id)keyboardDidShow{
    CGRect keyboardRect = [[keyboardDidShow userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    verifyButtonBottomConstraint.constant = keyboardRect.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    
    NSDictionary *userInfo = [keyboardDidShow userInfo];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(id)keyboardDidHide{
    verifyButtonBottomConstraint.constant = 0;
    
    [UIView beginAnimations:nil context:NULL];
    
    NSDictionary *userInfo = [keyboardDidHide userInfo];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

@end
