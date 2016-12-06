#import "SEReceiptVC.h"
#import "Constant.h"
#import <GeekNavi/GeekNaviStarRatingView.h>

static double tipValue = 0.0f;

@interface SEReceiptVC (){
    // UILabels
    __weak IBOutlet UILabel *finalCostLabel;
    
    // UIButtons
    __weak IBOutlet UIButton *submitButton;
    __weak IBOutlet UIButton *plusButton;
    __weak IBOutlet UIButton *minusButton;
    
    // UIImageViews
    __weak IBOutlet UIImageView *carimage;
    
    // Rating View
    __weak IBOutlet GeekNaviStarRatingView *starsRating;
    
    // Instance Variables
    NSDictionary *rideInfoDict;
    double finalCost;
}

@end

@implementation SEReceiptVC
@synthesize rideID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // As always, start with customizing the screen (MAIN/SUB Colors)
    [self customizeScreen];
    
    addLoading(@"");
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [self fetchDriverInformationWithRideID:rideID];
    
    [self fetchReceiptDetailsWithRideID:rideID successBlock:^(BOOL success) {
        if (success) {
            [self getFinalCost:^(BOOL complete) {
                if (complete) {
                    finalCostLabel.text = [NSString stringWithFormat:@"%.2f %@",finalCost,currency];
                    removeLoading();
                }
            }];
        }
    }];
}

#pragma mark - Increment Tip Action
- (IBAction)incrementPrice:(id)sender {
    [minusButton setEnabled:YES];
    
    tipValue += .5;
    
    finalCostLabel.text = [NSString stringWithFormat:@"%.2f %@",tipValue + finalCost,currency];
}

#pragma mark - Decrement Tip Action
- (IBAction)decrementPrice:(id)sender {
    if (tipValue == 0) {
        [minusButton setEnabled:NO];
        return;
    }
    
    tipValue -= .5;
    
    finalCostLabel.text = [NSString stringWithFormat:@"%.2f %@",tipValue + finalCost,currency];
}

#pragma mark - Report Driver Action
- (IBAction)reportDriver:(id)sender {
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

#pragma mark - Submit Rating Action
- (IBAction)submitraiting:(id)sender {
    [GeekNavi submitFeedBackForRide:(int)starsRating.value rideID:rideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess){
            addLoading(NSLocalizedString(@"processing_payment", nil));
            [self chargeAndUpdateTip];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - Fetch Driver Profile Image
-(void)fetchDriverInformationWithRideID:(int)rideidentifier{
    [GeekNavi getDriverInformationFromRideID:rideidentifier block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            // Got the drivers information
            NSString *pathToBackendPlusImageFolder = [pathToWebBackend stringByAppendingFormat:@"images/profile/original/%@",JSON[@"data"][@"vImage"]];
            downloadImageFromUrl(pathToBackendPlusImageFolder, carimage);
        }
    }];
}

#pragma mark - Fetch Receipt Details
-(void)fetchReceiptDetailsWithRideID:(int)rideIdentifier successBlock:(void(^)(BOOL success))callback{
    [GeekNavi getRideInformationFromRideID:rideIdentifier block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            rideInfoDict = [JSON[@"data"] copy];
            callback(YES);
        }else{
            callback(NO);
        }
    }];
}

#pragma mark - Fetch & Calculate Final Cost
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

#pragma mark - Update tip (if any) & Charge the user
-(void)chargeAndUpdateTip{
    // First, update tip
    [GeekNavi updateTipWithRideID:rideID totalTip:tipValue block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            // Then, charge
            [GeekNavi chargeUserWithRideID:rideID block:^(id JSON, WebServiceResult geekResult) {
                if(geekResult==WebServiceResultSuccess){
                    removeLoading();
                    // Transaction Success
                }else{
                    // Transaction Failed, so make the user's balance negative
                    [self updateUserBalanceAndCancelRide:finalCost];
                }
            }];
        }else{
            // Something failed, make the user's balance negative
            [self updateUserBalanceAndCancelRide:finalCost];
        }
    }];
}

#pragma mark - Transaction Failed
-(void)updateUserBalanceAndCancelRide:(double)failedTransactionTotal{
    showAlertViewWithTitleAndMessage(nil,NSLocalizedString(@"transaction_failed", nil));
    
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

#pragma mark - Customize Screen
-(void)customizeScreen{
    [self.view setBackgroundColor:MAIN_THEME_COLOR];
    
    starsRating.tintColor = SUB_THEME_COLOR;
    
    submitButton.layer.cornerRadius = 10.0f;
    submitButton.layer.masksToBounds = YES;
    
    [plusButton setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
    plusButton.layer.borderColor = SUB_THEME_COLOR.CGColor;
    plusButton.layer.borderWidth = 1.0f;
    
    [minusButton setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
    minusButton.layer.borderColor = SUB_THEME_COLOR.CGColor;
    minusButton.layer.borderWidth = 1.0f;
}


@end
