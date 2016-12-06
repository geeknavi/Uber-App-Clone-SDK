//
//  DriverRideCompleteViewController.m
//  GeekNavi
//
//  Created By GeekNavi on 7/22/16.

#import "DriverRideCompleteViewController.h"
#import <GeekNavi/GeekMapHelper.h>

@interface DriverRideCompleteViewController (){
    // Main UIView
    __weak IBOutlet UIView *mainview;
    
    // UILabels
    __weak IBOutlet UILabel *earnedLabel;
    
    // UIButtons
    __weak IBOutlet UIButton *doneButton;
}

@end

@implementation DriverRideCompleteViewController
@synthesize rideID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // As always, start with customizing the screen (MAIN/SUB Colors)
    [self customizeScreen];
    [self showEarnedValue];
}

#pragma mark - Show Earned Value
-(void)showEarnedValue{
    addLoading(@"");
    [GeekNavi getDriverFinalEarningsFromRideID:rideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            removeLoading();
            earnedLabel.text = [NSString stringWithFormat:@"Earned: %@ %@",JSON[@"data"],currency];
        }else{
            earnedLabel.text = @"Unavailable";
        }
    }];
}

#pragma mark - Customize Screen
-(void)customizeScreen{
    [mainview setBackgroundColor:MAIN_THEME_COLOR];
    mainview.layer.cornerRadius = 10.0f;
    mainview.layer.masksToBounds = YES;
    
    [earnedLabel setTextColor:SUB_THEME_COLOR];
    
    [doneButton setBackgroundColor:SUB_THEME_COLOR];
    doneButton.layer.cornerRadius = 10.0f;
    doneButton.layer.masksToBounds = YES;
}


@end
