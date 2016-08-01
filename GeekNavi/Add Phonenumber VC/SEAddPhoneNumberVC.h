//
//  SEAddPhoneNumberVC.h
//  GeekNavi
//
//  Created by GeekNavi on 3/13/16.
//
//

#import <UIKit/UIKit.h>
#import "GeekNaviCountryPicker.h"

@interface SEAddPhoneNumberVC : UIViewController<GeekNaviCountryPickerDelegate>

@property (nonatomic,strong) NSString *vFirst;
@property (nonatomic,strong) NSString *vLast;
@property (nonatomic,strong) NSString *vEmail;

@end
