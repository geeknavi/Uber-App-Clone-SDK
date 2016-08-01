//
//  SEPaymentViewController.m
//
//  Created by GeekNavi on 1/17/15.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "SEPaymentViewController.h"
#import "PaymentViewController.h"
#import "StripeError.h"

@interface SEPaymentViewController ()<STPBackendChargings>{
    __weak IBOutlet UIImageView *typeofcardpicture;
    __weak IBOutlet UILabel *lastfour;
    __weak IBOutlet UILabel *nocardregistered;
    __weak IBOutlet UIButton *addCardButton;
}

@end

@implementation SEPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:THEME_COLOR];
    [addCardButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Payment";
    
    [self checkifuserhascardregistered];
}
-(void)checkifuserhascardregistered{
    if ([userInformation[@"vToken"]isEqualToString:@""] || !userInformation[@"vToken"]) {
        nocardregistered.hidden=NO;
        nocardregistered.text = @"No card registered";
    }else{
        [self lastfourdigits];
    }
}
-(void)lastfourdigits{
    if (userInformation[@"last4"] && userInformation[@"vToken"]) {
    NSString *digits = [NSString stringWithFormat:@"*%@",userInformation[@"last4"]];
    
    lastfour.text = digits;
    
    nocardregistered.hidden=YES;
    
    if ([userInformation[@"typeofcard"]isEqualToString:@"Mastercard"]) {
      //  NSLog(@"Mastercard");
        UIImage *mastercard = [UIImage imageNamed: @"mastercardlast4.png"];
        typeofcardpicture.image=mastercard;
    }else if ([userInformation[@"typeofcard"]isEqualToString:@"Visa"]){
       // NSLog(@"Visa");
        UIImage *visa = [UIImage imageNamed: @"visalast4.png"];
        typeofcardpicture.image=visa;
    }else if ([userInformation[@"typeofcard"]isEqualToString:@"American"]){
       // NSLog(@"American Express");
        UIImage *american = [UIImage imageNamed: @"americanlast4.png"];
        typeofcardpicture.image=american;
    }else if ([userInformation[@"typeofcard"]isEqualToString:@"Discovery"]){
      //  NSLog(@"Discovery");
        UIImage *discovery = [UIImage imageNamed: @"discoverlast4.png"];
        typeofcardpicture.image=discovery;
    }else{
      //  NSLog(@"unknown card");
    }
        }
}
- (IBAction)addCard:(id)sender {
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
    paymentViewController.backendCharger = self;
    paymentViewController.typeStr = @"updateToken";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)createBackendChargeWithToken:(STPToken *)token error:(NSError *)error{
    if (!error) {
        [GeekNavi registerCreditCardWithToken:token.tokenId block:^(id JSON, WebServiceResult geekResult) {
            if (geekResult==WebServiceResultSuccess) {
                [self addedSuccessfully];
                [self lastfourdigits];
            }
        }];
    }else{
        showAlertViewWithMessage(error.localizedDescription);
    }
}
- (void)addedSuccessfully{
   UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                message:@"Card successfully created!"
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil];
    [successAlert show];
}

@end
