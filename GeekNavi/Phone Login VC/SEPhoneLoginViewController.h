//
//  SEPhoneLoginViewController.h
//  GeekNavi
//
//  Created by GeekNavi on 2/17/15.
//  Copyright (c) 2015 GeekNavi. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "GeekNavi/GeekNaviCountryPicker.h"

@interface SEPhoneLoginViewController : UIViewController <FBSDKLoginButtonDelegate,GeekNaviCountryPickerDelegate>
@end
