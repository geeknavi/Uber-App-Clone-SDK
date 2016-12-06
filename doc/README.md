GeekNavi iOS SDK
=============

Below are just a few examples, for more information - download the demo application.

## Setting up

Before you use the GeekNavi API, you must first get your access tokens by contacting us at `support@GeekNavi.com`. Once you've received a key, you could initialize GeekNavi in your AppDelegate.m file. Here's an example:

```obj-c
#import "GeekNavi.h"

[GeekNavi setGeekNaviAPIKey:@""]; // Your GeekNavi API Key

// Optional
[GeekNavi setInviteText:@"I.. Love.. GeekNavi!"];
[GeekNavi setThemeColor:[UIColor colorWithRed:22.0/255.0f green:156.0/255.0f blue:229.0/255.0 alpha:1.0f]]; // Theme color
[GeekNavi setGoogleAPIKey:@"API_KEY"];
[GeekNavi setBackendPath:@"http://mybackend.com/ws/"];
[GeekNavi setStripePK_Key:@"pk_test_yourKey"];
```

### Creating a New User

Here's a quick example of how to create a new user.

```obj-c
#import "GeekNavi.h"

[GeekNavi registerUserWithParameters:@{
                       @"vFirst":@"Geek",
                       @"vLast":@"User",
                       @"vEmail":@"geekuser@email.com",
                       @"vFbID":@"Optional"
                   };
                   image:self.img // Optional, could be nil if you don't want to register the user with an image
                   block:^(id JSON, WebServiceResult geekResult) {
                        if (geekResult==WebServiceResultSuccess){
                            // Login user
                        }
    }];
```

### Login Existing User

This example shows how easy it is to login an existing user:

```obj-c
// Login with Email
[GeekNavi loginUserWithEmail:@"email@email.com" block:^(id JSON, WebServiceResult geekResult) {
    if(geekResult==WebServiceResultSuccess){
        // Login Exisiting user
    }else{
        // Create a new account
    }
}];
    
// Login with Facebook
[GeekNavi loginUserWithFacebook:@"facebook_id" block:^(id JSON, WebServiceResult geekResult) {
    if(geekResult==WebServiceResultSuccess){
        // Login Exisiting user
    }else{
        // Create a new account
    }
}];

// Login with Phone number
[GeekNavi loginwithPhone:userphone block:^(id JSON, WebServiceResult geekResult) {
    if ([JSON[@"message"]isEqualToString:@"No user registered!"]){
        // Create a new account
    }else if ([JSON[@"status"]isEqualToString:@"0"]){
        // Login Exisiting user
    }
}];
```

### Requesting a 4 digit verficiation code

Sends a 4 digit verification code to the specified phone number, i.e: `+1 669 123 4567`.

```obj-c
[GeekNavi sendTextMessageToPhoneNumber:@"16691234567" block:^(id JSON, WebServiceResult geekResult) {
    if (geekResult==WebServiceResultSuccess) {
        int verificationCode = [JSON[@"message"] intValue];
    }
}];
```

### Initialize the Geek Menu
This is an example of how you could use the GeekNavi menu in your application. For a more visual experience, please download the demo application and take a look for yourself.

```obj-c
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
```

A few examples of: User Side Functionality
=============

## GeekMapHelper Class

In the example below we can easily get the current location of the user and add it to the MKMapView (mainMap in this example).

```obj-c
#import "GeekMapHelper.h"

GeekMapHelper *geekHelper = [[GeekMapHelper alloc] init];
geekHelper.delegate = self;

[geekHelper getCurrentLocation:^(float latitude, float longitude, CLLocation *location) {
    [geekHelper addOriginPin:location.coordinate mapview:mainMap];
    [geekHelper zoomToCoordinate:location.coordinate withMap:mainMap animated:NO];
} locationAddress:^(NSString *address) {
    if (address) {
        // Do something with the address (optional)
    }
}];
```

### Coordinates -> Address
```obj-c
[geekHelper getAddressFromCoordinates:mainMap.centerCoordinate returnBlock:^(NSString *address, BOOL success) {
    if (success) {
        // Got the address!
    }
}];
```

### Address -> Coordinates
```obj-c
[geekHelper getCoordinatesFromAddress:@"295 California St" returnBlock:^(CLLocationCoordinate2D coordinates, BOOL success) {
    if (success) {
        // Got the coordinates!
        }
    } returnedAddress:^(NSString *address) {
    if (address) {
        // This variable has the complete address, i.e: 295 California St, San Francisco, CA 94111
    }
}];
```

### Calculate distance between coords
```obj-c
[geekHelper calculateDistanceBetweenCoords:location.coordinate toCoords:geekHelper->destinationPoint.coordinate block:^(double miles) {
    if (miles > 0.1) { // Example use of this function would be to ask the driver if he's sure that he wants to 'complete' a ride
        // More than 0.1 mile away!.. Are you sure?
    }
}];
```

### Request a Ride
This example shows how easy it is to make a user side request with GeekNavi. For more information about the ivars in this example, please download our demo application.
```obj-c
[GeekNavi bookRideWithDetails:geekHelper->originPinPoint.coordinate.latitude fromLongitude:geekHelper->originPinPoint.coordinate.longitude toLatitude:geekHelper->destinationPoint.coordinate.latitude toLongitude:geekHelper->destinationPoint.coordinate.longitude fromAddress:geekHelper->originPinPoint.title toAddress:geekHelper->destinationPoint.title totalCost:totalPrice block:^(id JSON, WebServiceResult geekResult) {
                if (geekResult==WebServiceResultSuccess) {
                    if ([JSON[@"message"]isEqualToString:@"No active drivers"]) {
                        // No drivers are online
                    }else{
                        requestingLabel.text = @"Looking for a driver...";
                    if (JSON[@"rideID"]) {
                        currentRideID = [JSON[@"rideID"] intValue];
                        [geekHelper startTrackingRideUpdatesWithRideID:currentRideID]; // Success.. Let's wait until a driver accepts
                }else{
                // Process error
            }
        }
    }
}];
```

### Get driver information from Ride ID
```obj-c
[GeekNavi getDriverInformationFromRideID:currentRideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            if (JSON[@"data"])  {
            // Got the info!
            }else{
            // Process Error
        }
    }
}];
```

### Track Drivers Position
```obj-c
// Call to start tracking the drivers position (requires that a driver has accepted the Ride, for more info, look at the demo app)
[geekHelper startTrackingDriversPosition];

-(void)driverPositionUpdates:(CLLocationCoordinate2D)currentCoords statusCode:(int)statusCode{
/*
    This delegate only updates if you've called "startTrackingDriversPosition"
    AND the drivers position has been updated
*/
    [geekHelper moveDriverPin:currentCoords mapview:mainMap];
    
    
    /*
        Status Code Explanation:
        
        1: Driver Accepted Ride
        2: The driver canceled the ride
        3: The Ride has been marked as complete by the driver
        4: Driver has picked up the user and is on route to the destination
    */
    
    if (statusCode == 1) { // A driver has accepted the ride
        //
    }else if(statusCode == 4){ // Driver has picked up user and is on route to destination
        //
    }
}
```

### Cancel a Ride
```obj-c
[GeekNavi cancelRideWithRideID:currentRideID block:^(id JSON, WebServiceResult geekResult) {
    if (geekResult==WebServiceResultSuccess) {
        // Success!
    }else{
        // Process Error
    }
}];
```

A few examples of: Driver Side Functionality
=============

Below you can find some of the available driver API's. For more details, please download the sample application and take a look for yourself.

### Init Driver Mode
```obj-c
[GeekNavi driverOnline:YES block:^(id JSON, WebServiceResult geekResult) {
    if (geekResult==WebServiceResultSuccess) {
        // Online!
        [geekHelper startLookingForRides];
    }
}];
```

### Look for Ride Requests
```obj-c
#import "GeekNavi.h"
#import "GeekMapHelper.h"

@interface MyViewController (){
    GeekMapHelper *geekHelper;
}
-(void)viewDidLoad{
    geekHelper = [[GeekMapHelper alloc] init];
    geekHelper.delegate = self;
}

[geekHelper startLookingForRides]; // Call this when you want to look for new Rides (driver side)

-(void)fetchedAvailableRidesForDriver:(NSDictionary *)info{ // Delegate method
    if (info.count > 0) { // If there's a new ride available
        [geekHelper stopLookingForRides]; // Then stop looking for new rides
        
        AudioServicesPlaySystemSound(1007); // Play a system sound
        
        currentRideID = [info[@"iFeedID"] intValue]; // currentRideID is just an IVAR
        
        [GeekNavi getUserInformationFromUserID:[info[@"iUserID"] intValue] block:^(id JSON, WebServiceResult geekResult) { // Get user info
            if (geekResult==WebServiceResultSuccess) {
                // Do something with the user's information
            }
        }];
    }
}
```

### Accept a Ride Request
```obj-c
[GeekNavi acceptRide:currentRideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            // Success!
        }else{
            // Process error
        }
    }];
```

### Send Text Message update
(Optional) Sends a text message to the user that requested the ride with the message "Your driver has arrived!"
```obj-c
[GeekNavi sendTextMessageToUserFromRideID:currentRideID message:@"Your driver has arrived!" block:^(id JSON, WebServiceResult geekResult) {
    if (geekResult==WebServiceResultSuccess) {
        //
    }
}];
```

### These are just a few examples, for more information - download the demo application.