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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GeekNavi/GeekGuillotineMenu.h>
#import "AppConfiguration.h"

// Drawing functions
#import <GeekNavi/GeekDrawHome.h>
#import <GeekNavi/GeekDrawCreditCard.h>
#import <GeekNavi/GeekDrawSteeringWheel.h>
#import <GeekNavi/GeekDrawSettings.h>
#import <GeekNavi/GeekDrawLogout.h>

// Google Search Functionality
@import GooglePlaces;

@interface AppDelegate ()<GeekGuillotineMenuDelegate>

@end

@implementation AppDelegate

-(instancetype)init{
    if ( self = [super init] ) {
        /*
            Change any of these controllers to your own values if you'd like to customize the menu
        */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        SEMainViewController  *menuVC   = (SEMainViewController *)[storyboard instantiateViewControllerWithIdentifier:@"mainStoryboardID"];
        SEPaymentViewController  *paymentVC   = (SEPaymentViewController *)[storyboard instantiateViewControllerWithIdentifier:@"paymentStoryboardID"];
        SEBecomeADriver *applyToDriveVC   = (SEBecomeADriver *)[storyboard instantiateViewControllerWithIdentifier:@"becomeADriverStoryboardID"];
        ProfileEditViewController *settingsVC   = (ProfileEditViewController *)[storyboard instantiateViewControllerWithIdentifier:@"profileStoryboardID"];
        
        self.vcArray        = @[menuVC, paymentVC, applyToDriveVC, settingsVC,LOGOUTBTN];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [GeekNavi setGeekNaviAPIKey:__GEEK_API_KEY]; // Your GeekNavi API Key
    
    [GeekNavi setMainThemeColor:__MAIN_THEME_COLOR];
    [GeekNavi setSubThemeColor:__SUB_THEME_COLOR];
    
    [GeekNavi setStripePK_Key:__STRIPE_API_KEY]; // GeekNavi's Test Key, implement your own if you're not testing solely for demo purposes
    
    [GeekNavi setGroupIDIdentifier:@"group.sharingdata.ride"]; // Found under "Capabilities"
    
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
     (Optional) Set your Google API Key
     - You could skip this step if you don't want to search with Google. In which case, replace current functionality with GeekNavi's resolving functionality (coords->address, string->address, etc.)
    */
    [GMSPlacesClient provideAPIKey:__GOOGLE_API_KEY];
    
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
     GeekNavi Root Navigation Controller (Loaded once a user is successfully logged in
    */
    
    NSArray *titlesArray    = @[[NSLocalizedString(@"home", nil) uppercaseString],
                                [NSLocalizedString(@"payment", nil) uppercaseString],
                                [NSLocalizedString(@"drive", nil) uppercaseString],
                                [NSLocalizedString(@"profile", nil) uppercaseString],
                                [NSLocalizedString(@"logout", nil) uppercaseString]
                                ];
    NSArray *imagesArray    = @[[GeekDrawHome imageOfHomeWithRect:CGRectMake(0, 0, 25, 25) color:SUB_THEME_COLOR],
                                [GeekDrawCreditCard imageOfCreditCardWithRect:CGRectMake(0, 0, 25, 18) color:SUB_THEME_COLOR],
                                [GeekDrawSteeringWheel imageOfWheelWithRect:CGRectMake(0, 0, 25, 25) color:SUB_THEME_COLOR],
                                [GeekDrawSettings imageOfSettingsWithFrame:CGRectMake(0, 0, 25, 25) color:SUB_THEME_COLOR],
                                [GeekDrawLogout imageOfExitWithRect:CGRectMake(0, 0, 25, 25) color:SUB_THEME_COLOR]];
    
    GeekGuillotineMenu *geekGuillotineMenu = [[GeekGuillotineMenu alloc] initWithViewControllers:self.vcArray MenuTitles:titlesArray andImages:imagesArray andStyle:GeekGuillotineMenuStyleTable];
    geekGuillotineMenu.menuColor = MAIN_THEME_COLOR;
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
    [GeekNavi removeGeekToken];
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
    showAlertViewWithTitleAndMessage(nil,@"Alerts are for your own convenience. If you change your mind, please allow GeekNavi under Settings.");
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
- (void)applicationDidBecomeActive:(UIApplication *)application{
    application.applicationIconBadgeNumber = 0;
    [FBSDKAppEvents activateApp];
}

@end
