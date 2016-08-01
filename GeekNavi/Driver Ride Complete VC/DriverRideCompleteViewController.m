//
//  DriverRideCompleteViewController.m
//  GeekNavi
//
//  Created By GeekNavi on 7/22/16.
//
//

#import "DriverRideCompleteViewController.h"
#import "GeekMapHelper.h"

@interface DriverRideCompleteViewController (){
    __weak IBOutlet UIView *mainview;
    __weak IBOutlet UILabel *earnedLabel;
    __weak IBOutlet UIButton *doneButton;
}

@end

@implementation DriverRideCompleteViewController
@synthesize rideID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GeekNavi getDriverFinalEarningsFromRideID:rideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            earnedLabel.text = [NSString stringWithFormat:@"Earned: %@ %@",JSON[@"data"],currency];
        }
    }];
}

#pragma mark - Customize Screen
-(void)customizeScreen{
    [doneButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [mainview setBackgroundColor:THEME_COLOR];
}


@end
