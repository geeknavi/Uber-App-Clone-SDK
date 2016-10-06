//
//  IntentHandler.m
//  siriGeek
//
//  Created by Filip Busic on 9/17/16.
//  Copyright © 2016 GeekNavi. All rights reserved.
//

#import "IntentHandler.h"

@interface IntentHandler () <INRequestRideIntentHandling>

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {
    // This is the default implementation.  If you want different objects to handle different intents,
    // you can override this and return the handler you want for that particular intent.
    
    [GeekNavi setGroupIDIdentifier:@"group.sharingdata.ride"];
    [GeekNavi setGeekNaviAPIKey:@""]; // Your GeekNavi API Key
    
    /*
     (Required after Purchase)
     
     [GeekNavi setBackendPath:@"http://mybackend.com/ws/"];
    */
    
    return self;
}

#pragma mark - Handle request ride
-(void)handleRequestRide:(INRequestRideIntent *)intent completion:(void (^)(INRequestRideIntentResponse * _Nonnull))completion{
    [GeekNavi geekHandleRequestRide:intent successMessage:NSLocalizedString(@"siri_success_book", nil) response:^(INRequestRideIntentResponse *result) {
        completion(result);
    }];
}

#pragma mark - Pickup Location
-(void)resolvePickupLocationForRequestRide:(INRequestRideIntent *)intent withCompletion:(void (^)(INPlacemarkResolutionResult * _Nonnull))completion{
    completion([GeekNavi geekResolvePickupLocationForRequestRide:intent]);
}

#pragma mark - Drop off location
-(void)resolveDropOffLocationForRequestRide:(INRequestRideIntent *)intent withCompletion:(void (^)(INPlacemarkResolutionResult * _Nonnull))completion{
    completion([GeekNavi geekResolveDropOffLocationForRequestRide:intent]);
}

@end
