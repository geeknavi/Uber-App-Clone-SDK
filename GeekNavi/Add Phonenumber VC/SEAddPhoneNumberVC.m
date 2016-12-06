//
//  SEAddPhoneNumberVC.m
//  GeekNavi
//
//  Created by GeekNavi on 3/13/16.
//
//

#import "SEAddPhoneNumberVC.h"
#import "SETermsAndCondiViewController.h"
#import "SECodeSentPhoneLoginViewController.h"

@interface SEAddPhoneNumberVC (){
    // UIButtons
    __weak IBOutlet UIButton *setCountryBtn;
    __weak IBOutlet UIButton *nextBtn;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UIButton *agreeButton;
    
    // UILabels
    __weak IBOutlet UILabel *titleLabel;
    
    // UITextFields
    __weak IBOutlet UITextField *phoneNumberTextField;
    
    // Constraints
    __weak IBOutlet NSLayoutConstraint *nextButtonBottomConstraint;
    
    // Country Picker
    __weak IBOutlet GeekNaviCountryPicker *countryPickerView;
    
    // Instance variables
    NSString *countryCode;
    NSString *numberCode;
    UIButton *countryButton;
}

@end

@implementation SEAddPhoneNumberVC
@synthesize vFirst,vLast,vEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeButtonsAndLabels];
    [self customizeTextFieldAndAddButton];
    
    // Sign up for keyboard notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    [countryPickerView setHidden:NO];
    [nextBtn setHidden:YES];
    [phoneNumberTextField setHidden:YES];
    [setCountryBtn setHidden:NO];
    [self.view endEditing:YES];
    NSLog(@"tapped change country");
}

#pragma mark - Delegate Action when picker did select
-(void)GeekNaviCountryPicker:(GeekNaviCountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code{
    countryCode = code;
    numberCode = [GeekNaviCountryPicker getCountryCode:code];
}

#pragma mark - Agree action
- (IBAction)agreeAction:(id)sender {
    agreeButton.selected=!agreeButton.selected;
}

#pragma mark - Set Country Action
- (IBAction)setCountryAction:(id)sender {
    [setCountryBtn setHidden:YES];
    [countryPickerView setHidden:YES];
    [nextBtn setHidden:NO];
    [phoneNumberTextField setHidden:NO];
    [phoneNumberTextField becomeFirstResponder];
    
    [GeekNaviCountryPicker changeFlagDependingOnCode:countryCode returnImage:^(UIImage *image) {
        if (image) {
            [countryButton setImage:image forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - View Terms Action
- (IBAction)viewTerms:(id)sender {
    [self performSegueWithIdentifier:@"viewTerms" sender:self];
}

#pragma mark - Next Button Action
- (IBAction)nextButtonAction:(id)sender {
    if (!agreeButton.selected) {
        showAlertViewWithTitleAndMessage(nil,NSLocalizedString(@"terms_not_agree", nil));
        return;
    }
    [self performSegueWithIdentifier:@"verifyPhoneNumber" sender:self];
}

#pragma mark - Back Button Action
- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Customizing Theme color and corner radius
-(void)customizeButtonsAndLabels{
    [self.view setBackgroundColor:MAIN_THEME_COLOR];
    
    [titleLabel setTextColor:SUB_THEME_COLOR];
    [backBtn setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
    [nextBtn setBackgroundColor:SUB_THEME_COLOR];
    [setCountryBtn setBackgroundColor:SUB_THEME_COLOR];
}

#pragma mark - Prepare for Segue
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"verifyPhoneNumber"]) {
        SECodeSentPhoneLoginViewController *vc = (SECodeSentPhoneLoginViewController *)[segue destinationViewController];
        vc.userphone = [NSString stringWithFormat:@"%@%@",numberCode,phoneNumberTextField.text];
        vc.vFirst = vFirst;
        vc.vLast = vLast;
        vc.vEmail = vEmail;
        vc.userRegister = YES;
    }
}

#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(id)keyboardDidShow{
    CGRect keyboardRect = [[keyboardDidShow userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    nextButtonBottomConstraint.constant = keyboardRect.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    
    NSDictionary *userInfo = [keyboardDidShow userInfo];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(id)keyboardDidHide{
    nextButtonBottomConstraint.constant = 0;
    
    [UIView beginAnimations:nil context:NULL];
    
    NSDictionary *userInfo = [keyboardDidHide userInfo];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

@end
