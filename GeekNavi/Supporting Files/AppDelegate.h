//
//  AppDelegate.h
//  GeekNavi
//
//  Created by Filip Busic on 7/26/16.
//  Copyright © 2016 GeekNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *vcArray;

-(void)initializeMainRootViewController;

@end

