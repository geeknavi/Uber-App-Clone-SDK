//
//  PayoutSettingsViewController.m
//  GeekNavi
//
//  Created by GeekNavi on 11/25/16.
//  Copyright © 2016 GeekNavi. All rights reserved.
//

#import "PayoutSettingsViewController.h"
#import "NYAlertViewController.h"

@interface PayoutSettingsViewController (){
    // UILabels
    __weak IBOutlet UILabel *currentEarningsLabel;
    __weak IBOutlet UILabel *weeklyEarningsLabel;
    __weak IBOutlet UILabel *monthlyEarningsLabel;
    
    // UIButtons
    __weak IBOutlet UIButton *editPaypalAddressButton;
    __weak IBOutlet UIButton *requestPayoutButton;
}

@end

@implementation PayoutSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // As always, start with customizing the screen (MAIN/SUB Colors)
    [self customizeScreen];
    [self updateLabelsWithEarnings];
}

#pragma mark - Edit/Add Paypal Action
- (IBAction)editPaypalAddressAction:(id)sender {
    addLoading(@"");
    [GeekNavi fetchDriversPayPalEmail:^(id JSON, WebServiceResult geekResult) {
        removeLoading();
        if (geekResult==WebServiceResultSuccess) {
            if ([JSON[@"data"] length] == 0) {
                [self bringUpChangeableTextfield];
            }else{
                NSString *userPaypalAddress = JSON[@"data"];
                
                // Bring up "We have XXX as your paypal address, would you like to change it?"
                NYAlertViewController *alertViewController = [NYAlertViewController
                                                              alertControllerWithTitle:@"Edit Paypal Email Address"
                                                              message:[NSString stringWithFormat:@"We have %@ as your PayPal Email Address, would you like to change it?",userPaypalAddress]
                                                              mainThemeColor:MAIN_THEME_COLOR
                                                              subThemeColor:SUB_THEME_COLOR
                                                              textColor:[UIColor darkGrayColor]
                                                              ];
                alertViewController.backgroundTapDismissalGestureEnabled = NO;
                [alertViewController addAction:[NYAlertAction
                                                actionWithTitle:@"Yes, change it!"
                                                style:UIAlertActionStyleDefault
                                                handler:^(NYAlertAction *action) {
                                                    [self dismissViewControllerAnimated:YES completion:^{
                                                        [self bringUpChangeableTextfield];
                                                    }];
                                                }]
                 ];
                
                [alertViewController addAction:[NYAlertAction
                                                actionWithTitle:@"No, keep it!"
                                                style:UIAlertActionStyleDestructive
                                                handler:^(NYAlertAction *action) {
                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                }]
                 ];
                
                [self presentViewController:alertViewController animated:YES completion:nil];
            }
        }
    }];
}

#pragma mark - Request Payout Action
- (IBAction)requestPayoutAction:(id)sender {
    addLoading(@"");
    [GeekNavi requestPayout:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            [self updateLabelsWithEarnings];
            if ([JSON[@"unPaidEarnings"] intValue] > 0) {
                showAlertViewWithTitleAndMessage(@"Success", [NSString stringWithFormat:@"Successfully requested %.2f %@",[JSON[@"unPaidEarnings"] doubleValue],currency]);
            }else{
                showAlertViewWithTitleAndMessage(nil, NSLocalizedString(@"payout_try_again_later", nil));
            }
        }
    }];
}

#pragma mark - Dismiss Action
- (IBAction)dismissButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Bring up Changeable Textfield Alert View
-(void)bringUpChangeableTextfield{
    NYAlertViewController *alertViewController = [NYAlertViewController
                                                  alertControllerWithTitle:@"Paypal Email Address"
                                                  message:@"Please enter your PayPal Email Address"
                                                  mainThemeColor:MAIN_THEME_COLOR
                                                  subThemeColor:SUB_THEME_COLOR
                                                  textColor:[UIColor darkGrayColor]
                                                  ];
    alertViewController.backgroundTapDismissalGestureEnabled = NO;
    alertViewController.swipeDismissalGestureEnabled = NO;
    [alertViewController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"email", nil);
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [textField becomeFirstResponder];
    }];
    
    NYAlertAction *submitAction = [NYAlertAction
                                   actionWithTitle:@"Submit"
                                   style:UIAlertActionStyleDefault
                                   handler:^(NYAlertAction *action) {
                                       addLoading(@"");
                                       UITextField *emailAddressTextField = [alertViewController.textFields firstObject];
                                       
                                       [GeekNavi updatePaypalDriverEmail:emailAddressTextField.text block:^(id JSON, WebServiceResult geekResult) {
                                           if (geekResult==WebServiceResultSuccess) {
                                               [self dismissViewControllerAnimated:YES completion:^{
                                                   showAlertViewWithTitleAndMessage(@"Success",NSLocalizedString(@"thank_you_payout_details", nil));
                                               }];
                                           }else{
                                               
                                               [self dismissViewControllerAnimated:YES completion:^{
                                                   showAlertViewWithTitleAndMessage(nil,NSLocalizedString(@"internet_connection_fail", nil));
                                               }];
                                           }
                                       }];
                                   }];
    submitAction.enabled = NO;
    
    // Disable the submit action until the user has filled out a valid email
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      UITextField *emailAddressTextField = [alertViewController.textFields firstObject];
                                                      submitAction.enabled = validateEmail(emailAddressTextField.text);
                                                  }];
    
    [alertViewController addAction:submitAction];
    
    [alertViewController addAction:[NYAlertAction
                                    actionWithTitle:@"Cancel"
                                    style:UIAlertActionStyleDestructive
                                    handler:^(NYAlertAction *action) {
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }]
     ];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
}

#pragma mark - Update Labels
-(void)updateLabelsWithEarnings{
    addLoading(@"");
    [GeekNavi getDriverCurrentEarnings:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            NSString *unpaidBalance = [NSString stringWithFormat:@"%.02f %@", [JSON[@"unPaidEarnings"] doubleValue],currency];
            NSString *weeklyEarnings = [NSString stringWithFormat:@"%.02f %@", [JSON[@"weeklyEarnings"] doubleValue],currency];
            NSString *monthlyEarnings = [NSString stringWithFormat:@"%.02f %@", [JSON[@"monthlyEarnings"] doubleValue],currency];
            
            currentEarningsLabel.text = unpaidBalance;
            weeklyEarningsLabel.text = weeklyEarnings;
            monthlyEarningsLabel.text = monthlyEarnings;
            
            removeLoading();
        }else{
            currentEarningsLabel.text = @"Unavailable";
            weeklyEarningsLabel.text = @"Unavailable";
            monthlyEarningsLabel.text = @"Unavailable";
        }
    }];
}

#pragma mark - Customize Screen
-(void)customizeScreen{
    [self.view setBackgroundColor:MAIN_THEME_COLOR];
    [requestPayoutButton setBackgroundColor:SUB_THEME_COLOR];
    
    requestPayoutButton.layer.cornerRadius = 10.0f;
    requestPayoutButton.layer.masksToBounds = YES;
    editPaypalAddressButton.layer.cornerRadius = 10.0f;
    editPaypalAddressButton.layer.masksToBounds = YES;
}

@end
