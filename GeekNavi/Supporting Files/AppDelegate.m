//
//  AppDelegate.m
//  GeekNavi
//
//  Created by GeekNavi on 09/06/14.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "AppDelegate.h"
#import "Constant.h"
#import "Stripe.h"
#import "SEMainViewController.h"
#import "ProfileEditViewController.h"
#import "SEPaymentViewController.h"
#import "SEBecomeADriver.h"
#import "LoginViewController.h"
#import "GeekGuillotineMenu.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface AppDelegate ()<GeekGuillotineMenuDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [GeekNavi setGeekNaviAPIKey:@""]; // Your GeekNavi API Key
    
    [GeekNavi setThemeColor:[UIColor colorWithRed:22.0/255.0f green:156.0/255.0f blue:229.0/255.0 alpha:1.0f]];
    
    [GeekNavi setStripePK_Key:@"pk_test_FuLAg7bUqPr0iKuQtS7W7xvB"]; // GeekNavi's Test Key, implement your own if you're not testing solely for demo purposes
    
    /*
     (Optional)
     
     [GeekNavi setInviteText:@"I.. Love.. GeekNavi!"];
     [GeekNavi setThemeColor:[UIColor colorWithRed:22.0/255.0f green:156.0/255.0f blue:229.0/255.0 alpha:1.0f]];
     [GeekNavi setGoogleAPIKey:@"API_KEY"];
     */
    
    /*
     (Required after Purchase)
     
     [GeekNavi setBackendPath:@"http://mybackend.com/ws/"];
     [GeekNavi setStripePK_Key:@"pk_test_yourKey"];
     */
    
    
    
    /*
     Initializing User Notifications (Push Notifications)
     */
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    if (STRIPE_PK_KEY) {
        [Stripe setDefaultPublishableKey:STRIPE_PK_KEY];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];;
}

-(void)initializeMainRootViewController{
    /*
     GeekNavi Root Navigation Controller (Loaded once a user is successfully logged in)
     
     Change any of these controllers to your own values if you'd like to customize the menu
     */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SEMainViewController  *menuVC   = [storyboard instantiateViewControllerWithIdentifier:@"mainStoryboardID"];
    SEPaymentViewController  *paymentVC   = [storyboard instantiateViewControllerWithIdentifier:@"paymentStoryboardID"];
    SEBecomeADriver *applyToDriveVC   = [storyboard instantiateViewControllerWithIdentifier:@"becomeADriverStoryboardID"];
    ProfileEditViewController *settingsVC   = [storyboard instantiateViewControllerWithIdentifier:@"profileStoryboardID"];
    
    self.vcArray        = @[menuVC, paymentVC, applyToDriveVC, settingsVC,LOGOUTBTN];
    NSArray *titlesArray    = @[@"HOME", @"PAYMENT", @"DRIVE", @"SETTINGS",@"LOG OUT"];
    NSArray *imagesArray    = @[@"ic_home", @"ic_payment", @"ic_drive", @"ic_settings",@"ic_logout"];
    
    GeekGuillotineMenu *geekGuillotineMenu = [[GeekGuillotineMenu alloc] initWithViewControllers:self.vcArray MenuTitles:titlesArray andImagesTitles:imagesArray andStyle:GeekGuillotineMenuStyleTable];
    geekGuillotineMenu.menuColor = THEME_COLOR;
    [geekGuillotineMenu setMenuDelegate:(AppDelegate *)[[UIApplication sharedApplication] delegate]];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:geekGuillotineMenu];
    
    [[UIApplication sharedApplication].keyWindow setRootViewController:navController];
}
-(void)didTapLogoutButton{
    
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
    UINavigationController *mainNavi = [storyboard instantiateViewControllerWithIdentifier:@"mainNaviController"];
    [mainNavi setViewControllers:@[loginVC]];
    [[UIApplication sharedApplication].keyWindow setRootViewController:mainNavi];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [GeekNavi setupPushNotifications:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    showAlertViewWithMessage(@"Alerts are for your own convenience. If you change your mind, please allow GeekNavi under Settings.");
}

- (void)applicationWillResignActive:(UIApplication *)application{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    [FBSDKAppEvents activateApp];
}

@end
