#import <UIKit/UIKit.h>
#import "STPToken.h"
#import "STPCheckoutViewController.h"

@class PaymentViewController;

@protocol STPBackendChargings <NSObject>

- (void)createBackendChargeWithToken:(STPToken *)token error:(NSError *)error;

@end

@interface PaymentViewController : UIViewController{
    IBOutlet UIButton *saveButton,*cancelButton;
    IBOutlet UILabel *label;

}

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic, weak) id<STPBackendChargings> backendCharger;
@property (nonatomic,retain)NSString *typeStr;


-(IBAction)save:(id)sender;


@end
