//
//  GeekMapHelper.h
//  GeekNavi
//
//  Created by GeekNavi on 7/17/16.
//
//

#import <MapKit/MapKit.h>
#import "GeekOriginPin.h"
#import "GeekDestinationPin.h"
#import "GeekDriverPin.h"

#undef weak_delegate
#if __has_feature(objc_arc_weak)
#define weak_delegate weak
#else
#define weak_delegate unsafe_unretained
#endif

typedef void(^latLong) (float latitude,float longitude, CLLocation *location);
typedef void(^address) (NSString *address);

@protocol GeekMapHelperDelegate <NSObject>
@optional

// User Side
-(void)rideStatusUpdates:(NSString *)currentStatus statusCode:(int)statusCode;
-(void)driverPositionUpdates:(CLLocationCoordinate2D)currentCoords statusCode:(int)statusCode;
-(void)failedToUpdateAuthorizationStatus:(NSError *)error;

// Driver Side
-(void)fetchedAvailableRidesForDriver:(NSDictionary *)info; // Called when a new ride is available
-(void)userCanceledDelegate; // Called when the user canceled the ride
@end

@interface GeekMapHelper : NSObject{
    @public
    GeekOriginPin *originPinPoint;
    GeekDestinationPin *destinationPoint;
    GeekDriverPin *driverPinPoint;
}

/*
 This method removes all available pins on the map
*/
-(void)removeAllPins:(MKMapView *)mapview;

/*
 This method adds a origin pin to the map
*/
-(void)addOriginPin:(CLLocationCoordinate2D)position mapview:(MKMapView *)mapview;

/*
 This method adds a destination pin to the map
*/
-(void)addDestinationPin:(CLLocationCoordinate2D)position mapview:(MKMapView *)mapview;

/*
 This method adds a drivers pin to the map
*/
-(void)addDriverPin:(CLLocationCoordinate2D)position mapview:(MKMapView *)mapview;

/*
 This method moves the drivers pin
*/
-(void)moveDriverPin:(CLLocationCoordinate2D)position mapview:(MKMapView *)mapview;

/*
 This method moves the users Origin/Destination Pin
*/
-(void)moveActivePin:(CLLocationCoordinate2D)position mapview:(MKMapView *)mapview;

/*
 This method sets the Origin pin (use manually unlock method to unlock)
*/
-(void)setOriginPin:(MKMapView *)mapview withAddress:(NSString *)address;

/*
 This method sets the Destination pin (use manually unlock method to unlock)
*/
-(void)setDestinationPoint:(MKMapView *)mapview withAddress:(NSString *)address;

/*
 This method unlocks the pin for movement
*/
-(void)manuallyUnlockPin:(id)pin;

/*
 This method zooms the map to fit the annotations
*/
-(void)zoomToFitMapAnnotations:(MKMapView*)mapview;

/*
 This method fetches the current location of the user
*/
-(void)getCurrentLocation:(latLong)block locationAddress:(address)locationAddress;

/*
 This method fetches the coordinates from an address
*/
-(void)getCoordinatesFromAddress:(NSString *)address returnBlock:(void(^)(CLLocationCoordinate2D coordinates, BOOL success))callback returnedAddress:(address)returnedAddress;

/*
 This method fetches the address from coordinates
*/
-(void)getAddressFromCoordinates:(CLLocationCoordinate2D)coordinates returnBlock:(void(^)(NSString *address, BOOL success))callback;

/*
 This method zooms the map to a set of coordinates
*/
-(void)zoomToCoordinate:(CLLocationCoordinate2D)coordinate withMap:(MKMapView *)mapview animated:(BOOL)animated;

/*
 This method draw lines between two coordinates on the map
*/
-(void)drawLinesWithFromCoords:(CLLocationCoordinate2D)fromCoords toCoords:(CLLocationCoordinate2D)toCoords mapview:(MKMapView *)mapview;

/*
 This method removes the lines from the map
*/
-(void)removeLinesFromMap:(MKMapView *)mapview;

/*
 This method draws the confirmation screen
*/
-(UIView *)drawConfirmation:(UIView *)view mapview:(MKMapView *)mapview costString:(NSString *)costString animated:(BOOL)animated;

/*
 This method fetches the prices from the Dashboard and calculates the price depending on the coordinates
*/
-(void)calculatePriceFromCoords:(CLLocationCoordinate2D)fromCoords toCoords:(CLLocationCoordinate2D)toCoords vehicleType:(int)vehicleType returnBlock:(void(^)(double price))callback;

/*
 This method tracks the ride updates with a specified Ride ID
*/
-(void)startTrackingRideUpdatesWithRideID:(int)rideID;

/*
 This method stops tracking the updates
*/
-(void)stopTrackingRideUpdates;

/*
 This method starts tracking the drivers position
*/
-(void)startTrackingDriversPosition;

/*
 This method stops tracking the drivers position
*/
-(void)stopTrackingDriversPosition;

/*
 Driver Side Methods
*/
-(void)startLookingForRides;

-(void)stopLookingForRides;

-(void)startBroadcastingLocationToUserWithRideID:(int)rideID;

-(void)stopBroadcastingLocationToUser;

-(void)startTrackingUserCancellationWithRideID:(int)rideID;

-(void)stopTrackingUserCancellation;

-(void)calculateDistanceBetweenCoords:(CLLocationCoordinate2D)fromCoords toCoords:(CLLocationCoordinate2D)toCoords block:(void(^)(double miles))callback;

@property (nonatomic, weak_delegate) id<GeekMapHelperDelegate> delegate;

@end