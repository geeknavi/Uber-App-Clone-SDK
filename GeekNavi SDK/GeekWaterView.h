#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GeekWaterView : UIView{
    /*
        User Side
    */
    // Cancel Booking button (displayed before a driver has accepted)
    UIButton *cancelBookingButton;
    
    // Call Button (displayed in the view)
    UIButton *callButton;
    
    // Message Button (displayed in the view)
    UIButton *messageButton;
    
    // Cancel Button (displayed in the view)
    UIButton *cancelButton;
    
    
    /*
      Driver Side
    */
    // Accept Ride Button (driver's view, displayed when a new ride is available)
    UIButton *acceptRideButton;
    
    // Cancel Ride Button (driver's view, displayed when a new ride is available)
    UIButton *cancelRideButton;
}

@property (nonatomic,strong) UIColor *watercolor;

/*
 //////////////////////////////////////////////////////////////////////////////////////////
                                    User Side
 //////////////////////////////////////////////////////////////////////////////////////////
*/

// Adds the drivers information to the waterview
-(void)addDriverInformation:(NSString *)fullName rideStatus:(NSString *)rideStatus driverPhoneNumber:(NSString *)driverPhoneNumber driverRating:(int)driverRating driverProfileImage:(NSString *)driverProfileImage;

@property (nonatomic) BOOL containsDriverInfo;

// Stops animating the water view
-(void)stopAnimating;

// Starts animating the users request
-(void)animateRequesting;

// Updates the ETA Label
-(void)updateETA:(CLLocationCoordinate2D)fromCoords currentDriverCoords:(CLLocationCoordinate2D)currentDriverCoords;

// Updates the status of the Ride (picking up, dropping off)
-(void)updateRideStatus:(NSString *)rideStatus;

/*
 //////////////////////////////////////////////////////////////////////////////////////////
                                    Driver Side
 //////////////////////////////////////////////////////////////////////////////////////////
*/

// Adds a new ride notification with the following details and allows the driver to cancel/accept
-(void)displayNewRideWithInfo:(NSString *)fullName distance:(NSString *)distance userPhoneNumber:(NSString *)userPhoneNumber userProfileImage:(NSString *)userProfileImage;

// Appending the view with additional info (Call, Message and Cancel buttons)
-(void)appendOnRouteInfo;

// Updating the distance label
-(void)updateDistanceLabel:(NSString *)distance;

@end
