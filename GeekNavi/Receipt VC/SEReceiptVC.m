#import "SEReceiptVC.h"
#import "Constant.h"
#import "GeekNaviStarRatingView.h"

static double tipValue = 0.0f;

@interface SEReceiptVC (){
    __weak IBOutlet UILabel *bestLabel;
    __weak IBOutlet UILabel *worstLabel;
    __weak IBOutlet UIButton *submitBtn;
    __weak IBOutlet UIButton *reportdrivertext;
    __weak IBOutlet UIButton *plusButton;
    __weak IBOutlet UIButton *minusButton;
    
    __weak IBOutlet UIImageView *carimage;
    __weak IBOutlet UILabel *displaycost;
    
    __weak IBOutlet GeekNaviStarRatingView *starsRating;
    
    NSDictionary *rideInfoDict;
    
    double finalCost;
}

@end

@implementation SEReceiptVC
@synthesize rideID;

- (void)viewDidLoad {
    [super viewDidLoad];
    addLoading(@"");
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [self fetchDriverInformationWithRideID:rideID];
    
    [self fetchReceiptDetailsWithRideID:rideID successBlock:^(BOOL success) {
        if (success) {
            [self getFinalCost:^(BOOL complete) {
                if (complete) {
                    [self themeAndScreenOptimizations];
                    displaycost.text = [NSString stringWithFormat:@"%.2f %@",finalCost,currency];
                    removeLoading();
                }
            }];
        }
    }];
}
-(void)fetchDriverInformationWithRideID:(int)rideidentifier{
    [GeekNavi getDriverInformationFromRideID:rideidentifier block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            // Got the drivers information
            
            NSString *pathToBackendPlusImageFolder = [pathToWebBackend stringByAppendingFormat:@"images/profile/original/%@",JSON[@"data"][@"vImage"]];
            downloadImageFromUrl(pathToBackendPlusImageFolder, carimage);
        }
    }];
}
-(void)fetchReceiptDetailsWithRideID:(int)rideIdentifier successBlock:(void(^)(BOOL success))callback{
    if (!rideIdentifier || rideIdentifier == 0) {
        NSLog(@"Invalid Ride ID!");
        return;
    }
    
    [GeekNavi getRideInformationFromRideID:rideIdentifier block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            rideInfoDict = [JSON[@"data"] copy];
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}
-(void)getFinalCost:(void (^)(BOOL complete))callback{
    [GeekNavi getFinalCostFromRideID:rideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            finalCost = [JSON[@"data"] doubleValue];
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}
-(void)chargeAndUpdateTip{
    [GeekNavi updateTipWithRideID:rideID totalTip:tipValue block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            [GeekNavi chargeUserWithRideID:rideID block:^(id JSON, WebServiceResult geekResult) {
                if(geekResult==WebServiceResultSuccess){
                    removeLoading();
                    // Transaction Success
                }else{
                    // Transaction Failed
                    [self updateUserBalanceAndCancelRide:finalCost];
                }
            }];
        }else{
            [self updateUserBalanceAndCancelRide:finalCost];
        }
    }];
}
-(void)updateUserBalanceAndCancelRide:(double)failedTransactionTotal{
    showAlertViewWithMessage(NSLocalizedString(@"transaction_failed", nil));
    
    [GeekNavi updateUsersBalance:failedTransactionTotal block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            // Users balance is now negative
            [GeekNavi cancelRideWithRideID:rideID block:^(id JSON, WebServiceResult geekResult) {
                if (geekResult==WebServiceResultSuccess) {
                    // Ride is now canceled
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }];
}
#pragma mark - IBActions
- (IBAction)incrementPrice:(id)sender {
    [minusButton setEnabled:YES];
    
    tipValue += .5;
    
    displaycost.text = [NSString stringWithFormat:@"%.2f %@",tipValue + finalCost,currency];
}
- (IBAction)decrementPrice:(id)sender {
    if (tipValue == 0) {
        [minusButton setEnabled:NO];
        return;
    }
    
    tipValue -= .5;
    
    displaycost.text = [NSString stringWithFormat:@"%.2f %@",tipValue + finalCost,currency];
}
- (IBAction)reportdriver:(id)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Report the driver"
                                          message:@"Are you sure you want to report the driver? This report will be followed up on with one of our specalists."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *reportAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Report", @"Reset action")
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action){
                                      // Include your own report action
                                  }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Canceled");
                                   }];
    
    [alertController addAction:reportAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)submitraiting:(id)sender {
    [GeekNavi submitFeedBackForRide:(int)starsRating.value rideID:rideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            if ([[rideInfoDict[@"vPayment"] lowercaseString] isEqualToString:@"cash"]) {
                NSLog(@"User is paying cash. No need to charge the user via Stripe");
            }else{
                addLoading(NSLocalizedString(@"processing_payment", nil));
                [self chargeAndUpdateTip];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - Theme & screen optimizations
-(void)themeAndScreenOptimizations{
    if (IS_IPHONE4) {
        [bestLabel setHidden:YES];
        [worstLabel setHidden:YES];
        [starsRating setHidden:YES];
    }
    
    submitBtn.layer.cornerRadius = 5;
    submitBtn.layer.masksToBounds = YES;
    
    [self.view setBackgroundColor:THEME_COLOR];
    [submitBtn setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    
    plusButton.layer.borderColor=[UIColor whiteColor].CGColor;
    plusButton.layer.borderWidth=1.0f;
    
    minusButton.layer.borderColor=[UIColor whiteColor].CGColor;
    minusButton.layer.borderWidth=1.0f;
    
    carimage.layer.cornerRadius = carimage.frame.size.height /2;
    carimage.layer.masksToBounds = YES;
    carimage.layer.borderWidth = 0;
    carimage.layer.borderColor = [[UIColor whiteColor] CGColor];
    carimage.layer.borderWidth = 2.0f;
}


@end
