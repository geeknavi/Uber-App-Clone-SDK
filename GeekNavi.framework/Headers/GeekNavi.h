//
//  GeekNavi.h
//  GeekNavi
//
//  Created by GeekNavi on 7/9/16.
//  Copyright © 2016 GeekNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Intents/Intents.h>

#define INSURANCEPICTURE @"Ins"
#define CARPICTURE @"Car"
#define REGISTRATIONPIC @"Reg"

/*
 GeekNavi Main Theme Color
 
 Example: [UIColor whiteColor]
 */
extern UIColor *MAIN_THEME_COLOR;

/*
 GeekNavi Sub Theme Color
 
 Example: [UIColor colorWithRed:(float)22/255 green:(float)156/255  blue:(float)229/255  alpha:1.0]
 */
extern UIColor *SUB_THEME_COLOR;

/*
 GeekNavi Invite Text
 
 Example: I.. Love.. GeekNavi!
 */
extern NSString *INVITE_TEXT;

/*
 GeekNavi Path to Backend
 
 Example: https://www.mybackend.com/ws/
 */
extern NSString *pathToWebBackend;

/*
 Stripe API Key (Found under: https://dashboard.stripe.com/account/apikeys)
 
 Example: pk_test_ABCDEFGH...
 */
extern NSString *STRIPE_PK_KEY;

/*
 Google API Key (Optional)
 */
extern NSString *GOOGLE_API_KEY;

/*
 Global User's Information
 */
extern NSDictionary *userInformation;

/*
 Global Currency (Set in the Dashboard)
 */
extern NSString *currency;

/*
 Global Group ID (required to communicate with Siri)
*/
extern NSString *groupIDIdentifier;

/*
 GeekNavi Web Result ENUM
 */
typedef NS_ENUM (NSInteger, WebServiceResult)
{
    WebServiceResultSuccess = 0,
    WebServiceResultFail,
    WebServiceResultError
};

typedef void(^GeekNaviWebResultsBlock)(id JSON,WebServiceResult geekResult);


@interface GeekNavi : NSObject

/*
 Method that sets the Backend path
 */
+(void)setBackendPath:(NSString *)path;

/*
 Method that sets the GeekNavi API Key
 */
+(void)setGeekNaviAPIKey:(NSString *)key;

/*
 Method that sets the Main Theme color of the application
 */
+(void)setMainThemeColor:(UIColor *)color;

/*
 Method that sets the Sub Theme color of the application
 */
+(void)setSubThemeColor:(UIColor *)color;

/*
 Method that sets App Group Identifier (required to communicate with Siri)
 */
+(void)setGroupIDIdentifier:(NSString *)identifier;

/*
 Method that sets the Invite Text when user wants to share the app via text message
 */
+(void)setInviteText:(NSString *)text;

/*
 Method that sets the Stripe API Key
 */
+(void)setStripePK_Key:(NSString *)key;

/*
 Method that sets the Google API Key (OPTIONAL)
 */
+(void)setGoogleAPIKey:(NSString *)key;

/*
 This method allows you to edit the users information and (optional) change the profile image
 */
+(void)editUserInformationWithParameters:(NSDictionary *)params image:(UIImage *)image block:(GeekNaviWebResultsBlock)block;

/*
 This method fetches the current earnings of the driver
 */
+(void)getDriverCurrentEarnings:(GeekNaviWebResultsBlock)block;

/*
 This method fetches the final cost of a Ride
 */
+(void)getFinalCostFromRideID:(int)rideID block:(GeekNaviWebResultsBlock)block;

/*
 This method fetches the driver's earnings from a ride (ride total cost minus commission)
 */
+(void)getDriverFinalEarningsFromRideID:(int)rideID block:(GeekNaviWebResultsBlock)block;

/*
 This method submits the Ride and charges the user accordingly
 */
+(void)chargeUserWithRideID:(int)rideID block:(GeekNaviWebResultsBlock)block;

/*
 This method updates the user's tip on the receipt page
 */
+(void)updateTipWithRideID:(int)rideID totalTip:(double)totalTip block:(GeekNaviWebResultsBlock)block;

/*
 This method registers the credit card and returns a block
 */
+(void)registerCreditCardWithToken:(NSString *)token block:(GeekNaviWebResultsBlock)block;

/*
 This method updates the drivers Paypal email
 */
+(void)updatePaypalDriverEmail:(NSString *)email block:(GeekNaviWebResultsBlock)block;

/*
 This method fetches the drivers Paypal email
*/
+(void)fetchDriversPayPalEmail:(GeekNaviWebResultsBlock)block;

/*
 This method submits a payout request for the driver
*/
+(void)requestPayout:(GeekNaviWebResultsBlock)block;

/*
 This method submits the users feedback for a ride
 */
+(void)submitFeedBackForRide:(int)feedback rideID:(int)rideID block:(GeekNaviWebResultsBlock)block;

/*
 This method fetches the Ride information from a specific ride ID
 */
+(void)getRideInformationFromRideID:(int)rideid block:(GeekNaviWebResultsBlock)block;

/*
 This method fetches the user's information from a specific ride ID
 */
+(void)getUserInformationFromRideID:(int)rideid block:(GeekNaviWebResultsBlock)block;

/*
 This method fetches the user's information from a specific user ID
 */
+(void)getUserInformationFromUserID:(int)userID block:(GeekNaviWebResultsBlock)block;

/*
 This method fetches the driver's information from a specific ride ID
 */
+(void)getDriverInformationFromRideID:(int)rideid block:(GeekNaviWebResultsBlock)block;

/*
 This method cancels a ride with a specific ride ID
 */
+(void)cancelRideWithRideID:(int)rideid block:(GeekNaviWebResultsBlock)block;

/*
 This method updates the users balance (call this after the transaction failed)
 */
+(void)updateUsersBalance:(double)balance block:(GeekNaviWebResultsBlock)block;

/*
 A Boolean that return YES if the user has previously logged in & the credentials are stored
*/
+(BOOL)geekHasAccessToken;

/*
 Removes the GeekNavi token (call this when user wants to log out)
*/
+(void)removeGeekToken;

/*
 Logs in user with Facebook and returns a Web Result Block
 */
+ (void)loginUserWithFacebook:(NSString *)facebookID block:(GeekNaviWebResultsBlock)block;

/*
 Logs in user based on the stored details on his/hers phone and returns a block
 */
+ (void)loginUserWithEmail:(NSString *)vEmail block:(GeekNaviWebResultsBlock)block;

/*
 Logs in user with Phone Number and returns a Web Result Block
 */
+ (void)loginwithPhone:(NSString *)phoneNumber block:(GeekNaviWebResultsBlock)block;

/*
 Sends a 4 Digit Code to a Phone number and returns the code in the Web Result Block
 */
+ (void)sendTextMessageToPhoneNumber:(NSString *)number block:(GeekNaviWebResultsBlock)block;

/*
 Fetches the prices for a specific vehicle type
 */
+(void)fetchPricesForVehicleType:(int)vehicleType block:(GeekNaviWebResultsBlock)block;

/*
 Registers a new user and provides the response in the block
 */
+ (void)registerUserWithParameters:(NSDictionary *)params image:(UIImage *)image block:(GeekNaviWebResultsBlock)block;

/*
 Books a Ride with the details provided and returns the response in a block
 */
+(void)bookRideWithDetails:(double)fromLatitude fromLongitude:(double)fromLongitude toLatitude:(double)toLatitude toLongitude:(double)toLongitude fromAddress:(NSString *)fromAddress toAddress:(NSString *)toAddress totalCost:(double)totalCost block:(GeekNaviWebResultsBlock)block;

/*
 This method fetches any ride that the user has requested that have been accepted by a driver
 */
+(void)getActiveRideInfo:(GeekNaviWebResultsBlock)block;

/*
 Sets up Push Notifications and stores the token in the database
*/
+(void)setupPushNotifications:(NSData *)deviceToken;

/*
 Updates the user's last four digits of his/hers credit-card
 */
+ (void)updateLastFourDigits:(NSString *)digits typeOfCard:(NSString *)typeofcard;

/*
 Updates the drivers current status, either offline/online
 */
+(void)driverOnline:(BOOL)online block:(GeekNaviWebResultsBlock)block;

/*
 Updates the drivers current location
 */
+(void)broadcastLocationToRideID:(int)rideID latitude:(double)latitude longitude:(double)longitude block:(GeekNaviWebResultsBlock)block;

/*
 Fetches the available rides around the drivers latitude & longitude
 */
+(void)fetchAvailableRides:(double)latitude longitude:(double)longitude block:(GeekNaviWebResultsBlock)block;

/*
 Sends a text message to the user that requested the ride
 */
+(void)sendTextMessageToUserFromRideID:(int)rideID message:(NSString *)message block:(GeekNaviWebResultsBlock)block;

/*
 Sends a push message to the user that requested the ride
*/
+(void)sendPushMessageToUserFromRideID:(int)rideID message:(NSString *)message block:(GeekNaviWebResultsBlock)block;

/*
 Calculates the ETA of the closest driver to the latitude & longitude
*/
+(void)etaOfClosestDriver:(double)latitude longitude:(double)longitude callback:(void (^)(int minutes, BOOL success))callback;

/*
 Accepts the Ride request (driver side)
 */
+(void)acceptRide:(int)rideID block:(GeekNaviWebResultsBlock)block;

/*
 Marks the driver as arrived (driver side)
 */
+(void)markAsArrived:(int)rideID block:(GeekNaviWebResultsBlock)block;

/*
 Marks the ride as 'complete'
 */
+(void)completeRide:(int)rideID block:(GeekNaviWebResultsBlock)block;

/*
 Fetches the application state of the user (Pending etc.)
 */
+(void)getApplicationState:(GeekNaviWebResultsBlock)block;

/*
 This method resets the application state to 'pending' (waiting for approval)
 */
+(void)changeToPendingApplication:(GeekNaviWebResultsBlock)block;

/*
 This method finalizes the application with the final parameters
 */
+(void)finalizeApplication:(NSDictionary *)parameters block:(GeekNaviWebResultsBlock)block;

/*
 Uploads an image to the server (used when applying to be a driver)
 */
+(void)uploadImage:(NSString *)imageName image:(UIImage *)image block:(GeekNaviWebResultsBlock)block;

/*
 This method allows you to submit your own custom Post Call and return the results in a block
 */
+(void)customAPIPostCall:(NSString *)path parameters:(NSDictionary *)parameters block:(GeekNaviWebResultsBlock)block;

/*
 This method allows you to submit your own custom Get Call and return the results in a block
 */
+(void)customAPIGetCall:(NSString *)path parameters:(NSDictionary *)parameters block:(GeekNaviWebResultsBlock)block;

/*
 This methods handles the Siri request ride functionality
 */
+(void)geekHandleRequestRide:(INRequestRideIntent *)intent successMessage:(NSString *)successMessage response:(void (^)(INRequestRideIntentResponse *result))response;

/*
 This methods handles the pickup location for the Siri functionality
 */

+(INPlacemarkResolutionResult *)geekResolvePickupLocationForRequestRide:(INRequestRideIntent *)intent;

/*
 This methods handles the drop off location for the Siri functionality
 */

+(INPlacemarkResolutionResult *)geekResolveDropOffLocationForRequestRide:(INRequestRideIntent *)intent;

@end
