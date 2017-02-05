//
//  SEPaymentViewController.m
//
//  Created by GeekNavi on 1/17/15.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "SEPaymentViewController.h"
#import "PaymentViewController.h"
#import "StripeError.h"
#import <GeekNavi/GeekDrawCreditCard.h>

@interface SEPaymentViewController ()<STPBackendChargings>{
    // Image views
    __weak IBOutlet UIImageView *typeOfCardImageView;
    
    // Labels
    __weak IBOutlet UILabel *lastFourLabel;
    
    // Buttons
    __weak IBOutlet UIButton *addCardButton;
}

@end

@implementation SEPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // As always, start with customizing the screen (MAIN/SUB Colors)
    [self customizeScreen];
    
    // Set default image
    [typeOfCardImageView setImage:[GeekDrawCreditCard imageOfCreditCardWithRect:typeOfCardImageView.frame color:[UIColor darkGrayColor]]];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Payment";
    
    [self checkIfUserHasCardRegistered];
}

#pragma mark - Check if user has a Credit card
-(void)checkIfUserHasCardRegistered{
    if ([userInformation[@"vToken"]isEqualToString:@""] || !userInformation[@"vToken"]) {
        lastFourLabel.text = @"No card registered";
    }else{
        [self grabLastFourDigits];
    }
}

#pragma mark - Grab Last four from Credit card
-(void)grabLastFourDigits{
    if (userInformation[@"last4"] && userInformation[@"vToken"]) {
        lastFourLabel.text = [NSString stringWithFormat:@"*%@",userInformation[@"last4"]];

        if ([userInformation[@"typeofcard"]isEqualToString:@"Mastercard"]) {
            UIImage *mastercard = [UIImage imageNamed: @"mastercardlast4.png"];
            typeOfCardImageView.image=mastercard;
        }else if ([userInformation[@"typeofcard"]isEqualToString:@"Visa"]){
            UIImage *visa = [UIImage imageNamed: @"visalast4.png"];
            typeOfCardImageView.image=visa;
        }else if ([userInformation[@"typeofcard"]isEqualToString:@"American"]){
            UIImage *american = [UIImage imageNamed: @"americanlast4.png"];
            typeOfCardImageView.image=american;
        }else if ([userInformation[@"typeofcard"]isEqualToString:@"Discovery"]){
            UIImage *discovery = [UIImage imageNamed: @"discoverlast4.png"];
            typeOfCardImageView.image=discovery;
        }else{
            lastFourLabel.text = @"Unknown Card";
        }
    }
}

#pragma mark - Add Card action
- (IBAction)addCard:(id)sender {
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
    paymentViewController.backendCharger = self;
    paymentViewController.typeStr = @"updateToken";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Credit card Delegate
-(void)createBackendChargeWithToken:(STPToken *)token error:(NSError *)error{
    if (!error) {
        [GeekNavi registerCreditCardWithToken:token.tokenId block:^(id JSON, WebServiceResult geekResult) {
            if (geekResult==WebServiceResultSuccess) {
                showAlertViewWithTitleAndMessage(@"Success!", @"Card successfully created!");
                [self grabLastFourDigits];
            }
        }];
    }else{
        showAlertViewWithTitleAndMessage(nil,error.localizedDescription);
    }
}

#pragma mark - Customize Screen
-(void)customizeScreen{
    // Set theme relevant properties
    [self.view setBackgroundColor:MAIN_THEME_COLOR];
    [addCardButton setBackgroundColor:SUB_THEME_COLOR];
    
    // Continue with VC specific
    addCardButton.layer.cornerRadius = 10.0f;
    addCardButton.layer.masksToBounds = YES;
}

@end
