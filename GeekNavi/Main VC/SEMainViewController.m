//  SEMainViewController.m
//  GeekNavi
//  Created by GeekNavi on 7/11/16.

#import "SEMainViewController.h"
#import "GeekMapHelper.h"
#import "HTHorizontalSelectionList.h"
#import "GeekWaterView.h"
#import "DriverRideCompleteViewController.h"
#import <MessageUI/MessageUI.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SEReceiptVC.h"
#import "SEMoreInfoApplication.h"

static int vehicleType = 0;
static double totalPrice = 0.0;
static int currentRideID = 0;

static BOOL driverMode = NO;

@interface SEMainViewController ()<GeekMapHelperDelegate,MKMapViewDelegate,UITextFieldDelegate,HTHorizontalSelectionListDataSource,HTHorizontalSelectionListDelegate,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>{
    __weak IBOutlet UITextField *fromAddressTextField;
    __weak IBOutlet UILabel *fromLabel;
    __weak IBOutlet UIView *fromAddressView;
    __weak IBOutlet NSLayoutConstraint *fromAddressConstantY;
    __weak IBOutlet UIButton *setPickUpButton;
    __weak IBOutlet UIButton *navigationButton;
    __weak IBOutlet MKMapView *mainMap;
    UITapGestureRecognizer *tapToMovePin;
    NSString *applicationInfo;
    
    HTHorizontalSelectionList *vehicleTypeList;
    NSArray *selectionListArray;
    
    UIButton *backButton;
    UIView *priceView;
    UIView *bookingTint;
    
    
    GeekMapHelper *geekHelper;
    GeekWaterView *waterview;
    
    
    // Driver Side Ride Request View
    GeekWaterView *newRideView;
    UIButton *driverNavigateButton;
    UIButton *driverArrivedButton;
}

@end

@implementation SEMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeScreen];
    [self drawSelectors];
    [self addObservers];
    [self checkApplicationState];
    
    selectionListArray = @[@"Sedan",@"Sport",@"Limo"];
    
    tapToMovePin = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureHandler:)];
    [mainMap addGestureRecognizer:tapToMovePin];
    
    geekHelper = [[GeekMapHelper alloc] init];
    geekHelper.delegate = self;
    fromAddressTextField.delegate = self;
    
    [self getLocationAndAddPin];
    
    /*
     (Optional) The method below checks if the user had any previous stage if the app was terminated
     
     Example: If the user terminated the application when the driver was 'On Route', then this method pushes
     the user back to that state.
     */
    [self loadExitedStage];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
}

/*
 //////////////////////////////////////////////////////////////////////////////////////////////////
                                        User Mode
 //////////////////////////////////////////////////////////////////////////////////////////////////
*/

#pragma mark - Add Origin Pin to map & zoom to current location
-(void)getLocationAndAddPin{
    [geekHelper getCurrentLocation:^(float latitude, float longitude, CLLocation *location) {
        [geekHelper addOriginPin:location.coordinate mapview:mainMap];
        [geekHelper zoomToCoordinate:location.coordinate withMap:mainMap animated:NO];
    } locationAddress:^(NSString *address) {
        if (address) {
            fromAddressTextField.text = address;
        }
    }];
}

#pragma mark - Location Access Denied Delegate
-(void)failedToUpdateAuthorizationStatus:(NSError *)error{
    if (error) {
        showAlertViewWithMessage(NSLocalizedString(@"location_denied", nil));
    }
}

#pragma mark - Navigation Button
- (IBAction)navigationAction:(id)sender {
    [geekHelper getCurrentLocation:^(float latitude, float longitude, CLLocation *location) {
        if (mainMap.annotations.count == 0) {
            [geekHelper addOriginPin:location.coordinate mapview:mainMap];
        }else{
            [geekHelper moveActivePin:location.coordinate mapview:mainMap];
        }
        [geekHelper zoomToCoordinate:location.coordinate withMap:mainMap animated:YES];
    } locationAddress:^(NSString *address) {
        if (address) {
            fromAddressTextField.text = address;
        }
    }];
}

#pragma mark - Set Pickup Action
- (IBAction)setPickupAction:(id)sender {
    if (!userInformation[@"vToken"] || [userInformation[@"vToken"] length] == 0) {
        showAlertViewWithMessage(@"Please add a creditcard before continuing");
        return;
    }
    
    [geekHelper setOriginPin:mainMap withAddress:fromAddressTextField.text];
    
    CLLocationCoordinate2D tmpCoord;
    tmpCoord.latitude = mainMap.centerCoordinate.latitude;
    tmpCoord.longitude = mainMap.centerCoordinate.longitude+0.001500;
    
    [geekHelper addDestinationPin:tmpCoord mapview:mainMap];
    [geekHelper getAddressFromCoordinates:mainMap.centerCoordinate returnBlock:^(NSString *address, BOOL success) {
        if (success) {
            fromAddressTextField.text = address;
        }
    }];
    
    
    fromLabel.text = NSLocalizedString(@"to", nil);
    fromAddressTextField.placeholder = NSLocalizedString(@"to_address", nil);
    [setPickUpButton setTitle:NSLocalizedString(@"set_destination", nil) forState:UIControlStateNormal];
    [vehicleTypeList removeFromSuperview];
    [self drawBackbutton];
    
    [UIView animateWithDuration:.6 animations:^{
        [setPickUpButton setBackgroundColor:[UIColor colorWithRed:146.0/255.0 green:205.0/255.0 blue:32.0/255.0 alpha:0.95]];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.4 animations:^{
            [setPickUpButton setBackgroundColor:[UIColor colorWithRed:130.0/255.0 green:191.0/255.0 blue:18.0/255.0 alpha:0.95]];
        }];
    }];
    [setPickUpButton removeTarget:self action:@selector(setPickupAction:) forControlEvents:UIControlEventAllEvents];
    [setPickUpButton addTarget:self action:@selector(setDestinationAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Set Destination Action
- (IBAction)setDestinationAction:(id)sender{
    [geekHelper setDestinationPoint:mainMap withAddress:fromAddressTextField.text];
    
    [geekHelper drawLinesWithFromCoords:geekHelper->originPinPoint.coordinate toCoords:geekHelper->destinationPoint.coordinate mapview:mainMap];
    
    [setPickUpButton setBackgroundColor:[UIColor colorWithRed:44.0/255.0f green:62.0/255.0f  blue:80.0/255.0f  alpha:1.0f]];
    [setPickUpButton setTitle:NSLocalizedString(@"request_ride", nil) forState:UIControlStateNormal];
    
    [setPickUpButton removeTarget:self action:@selector(setDestinationAction:) forControlEvents:UIControlEventAllEvents];
    [setPickUpButton addTarget:self action:@selector(bookAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [navigationButton setHidden:YES];
    [fromAddressView setHidden:YES];
    
    [geekHelper calculatePriceFromCoords:geekHelper->originPinPoint.coordinate toCoords:geekHelper->destinationPoint.coordinate vehicleType:vehicleType returnBlock:^(double price) {
        
        totalPrice = price;
        
        NSString *costStringTemp;
        
        if ((int)price != 0) {
            costStringTemp = [NSString stringWithFormat:@"~%.2f - %.2f",price,price*1.25];
        }else{
            costStringTemp = NSLocalizedString(@"unavailable", nil);
        }
        
        priceView = [geekHelper drawConfirmation:self.view mapview:mainMap costString:costStringTemp animated:YES];
        if(![priceView isDescendantOfView:self.view]){
            [self.view addSubview:priceView];
        }
        
        [UIView animateWithDuration:.4 animations:^{
            [backButton setFrame:CGRectMake(8, 8, 50, 50)];
            self.navigationController.navigationBar.alpha = 0.0f;
            [priceView setFrame:CGRectMake(self.view.center.x - priceView.frame.size.width/2, self.view.frame.size.height-setPickUpButton.frame.size.height-priceView.frame.size.height-25, priceView.frame.size.width, priceView.frame.size.height)];
        } completion:^(BOOL finished) {
            self.navigationController.navigationBar.hidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }];
        
    }];
}

#pragma mark - Back Button Action
- (IBAction)backButtonAction:(id)sender{
    if ([setPickUpButton.titleLabel.text isEqualToString:NSLocalizedString(@"set_destination", nil)]) {
        [self backToStartingPoint];
    }else if ([setPickUpButton.titleLabel.text isEqualToString:NSLocalizedString(@"request_ride", nil)]) {
        
        self.navigationController.navigationBar.hidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        [backButton removeFromSuperview];
        [priceView removeFromSuperview];
        
        [geekHelper manuallyUnlockPin:geekHelper->destinationPoint];
        
        [setPickUpButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [setPickUpButton addTarget:self action:@selector(setDestinationAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [navigationButton setHidden:NO];
        [fromAddressView setHidden:NO];
        
        fromAddressTextField.placeholder = NSLocalizedString(@"to_address", nil);
        fromLabel.text = NSLocalizedString(@"to", nil);
        
        [setPickUpButton setTitle:NSLocalizedString(@"set_destination", nil) forState:UIControlStateNormal];
        [setPickUpButton setBackgroundColor:[UIColor colorWithRed:130.0/255.0 green:191.0/255.0 blue:18.0/255.0 alpha:0.95]];
        [geekHelper removeLinesFromMap:mainMap];
        [self drawBackbutton];
    }
}


#pragma mark - Book Action
-(IBAction)bookAction:(id)sender{
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    
    [UIView animateWithDuration:.4 animations:^{
        [setPickUpButton setAlpha:0.0f];
        [priceView setAlpha:0.0f];
        [backButton setAlpha:0.0f];
    } completion:^(BOOL finished) {
        if (finished) {
            [priceView removeFromSuperview];
            [backButton removeFromSuperview];
            
            bookingTint = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [bookingTint setBackgroundColor:THEME_COLOR];
            [bookingTint setAlpha:0.70f];
            
            UILabel *requestingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, self.view.frame.size.width, 35)];
            [requestingLabel setText:@"Booking.."];
            [requestingLabel setTextAlignment:NSTextAlignmentCenter];
            [requestingLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:27.0f]];
            [requestingLabel setTextColor:[UIColor whiteColor]];
            [bookingTint addSubview:requestingLabel];
            
            [self.view addSubview:bookingTint];
            
            waterview = [[GeekWaterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-225, self.view.frame.size.width, 225)];
            waterview.watercolor = [UIColor whiteColor];
            // Book Call
            [self.view addSubview:waterview];
            [waterview animateRequesting];
            
            if ((int)totalPrice != 0) {
                [GeekNavi bookRideWithDetails:geekHelper->originPinPoint.coordinate.latitude fromLongitude:geekHelper->originPinPoint.coordinate.longitude toLatitude:geekHelper->destinationPoint.coordinate.latitude toLongitude:geekHelper->destinationPoint.coordinate.longitude fromAddress:geekHelper->originPinPoint.title toAddress:geekHelper->destinationPoint.title totalCost:totalPrice block:^(id JSON, WebServiceResult geekResult) {
                    if (geekResult==WebServiceResultSuccess) {
                        if ([JSON[@"message"]isEqualToString:@"No active drivers"]) {
                            [self backToStartingPoint];
                            showAlertViewWithMessage(NSLocalizedString(@"no_active_drivers", nil));
                        }else{
                            requestingLabel.text = @"Looking for a driver...";
                            if (JSON[@"rideID"]) {
                                currentRideID = [JSON[@"rideID"] intValue];
                                [geekHelper startTrackingRideUpdatesWithRideID:currentRideID];
                            }else{
                                showAlertViewWithMessage(@"Something went wrong.. Try again later!");
                            }
                        }
                    }
                }];
            }else{
                showAlertViewWithMessage(@"Something went wrong.. Try again later!");
            }
        }
    }];
}

#pragma mark - Cancel Ride Action (User side)
-(IBAction)cancelAction:(id)sender{
    // Place your own IF statements here if you'd like a cancellation fee
    // Example: IF a driver has accepted/is on route, then charge user $X.XX.
    
    [GeekNavi cancelRideWithRideID:currentRideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            [self backToStartingPoint];
        }else{
            showAlertViewWithMessage(@"Something went wrong.. Please try again!");
        }
    }];
}

#pragma mark - Gift Icon Action (upper right corner)
-(IBAction)giftIconAction:(id)sender{
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.body = INVITE_TEXT;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Message Delegate for Gift Action
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch(result) {
        case MessageComposeResultCancelled:
            NSLog(@"Canceled");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MessageComposeResultSent:
            NSLog(@"Shared to someone");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MessageComposeResultFailed:
            NSLog(@"Failed to send");
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}

#pragma mark - Booking/Location Updates
-(void)rideStatusUpdates:(NSString *)currentStatus statusCode:(int)statusCode{
    [waterview updateRideStatus:[currentStatus capitalizedString]];
    
    /*
        Status Code Explanation:
        
        1: Driver Accepted Ride
        2: The driver canceled the ride
        3: The Ride has been marked as complete by the driver
        4: Driver has picked up the user and is on route to the destination
    */
    
    if (!waterview.containsDriverInfo && (statusCode == 1 || statusCode == 4)) {
            [GeekNavi getDriverInformationFromRideID:currentRideID block:^(id JSON, WebServiceResult geekResult) {
                if (geekResult==WebServiceResultSuccess) {
                    if (JSON[@"data"])  {
                        [waterview addDriverInformation:[NSString stringWithFormat:@"%@ %@",JSON[@"data"][@"vFirst"],JSON[@"data"][@"vLast"]] rideStatus:[currentStatus capitalizedString] driverPhoneNumber:JSON[@"data"][@"userPhone"] driverRating:[JSON[@"data"][@"rating"] intValue] driverProfileImage:JSON[@"data"][@"vImage"]];
                        [waterview stopAnimating];
                    }else{
                        showAlertViewWithMessage(@"Something went wrong.. Please try again later!");
                        [self backToStartingPoint];
                    }
                }
            }];
        
        [bookingTint removeFromSuperview];
        [mainMap removeGestureRecognizer:tapToMovePin];
        
        [geekHelper addDriverPin:CLLocationCoordinate2DMake(0, 0) mapview:mainMap]; // Adding it as 0.0 for now and waiting for updates from delegate
        [geekHelper removeLinesFromMap:mainMap];
        
        [geekHelper startTrackingDriversPosition];
    }
    
    if (statusCode == 2){ // The driver canceled the ride
        showAlertViewWithMessage(@"The Ride has been canceled");
        [self backToStartingPoint];
    }else if (statusCode == 3){ // The Ride has been marked as complete by the driver
        [self performSegueWithIdentifier:@"completeRideSegue" sender:nil];
        [self backToStartingPoint];
    }else if (statusCode == 4){ // Driver has picked up the user and is on route to the destination
        //
    }
}

-(void)driverPositionUpdates:(CLLocationCoordinate2D)currentCoords statusCode:(int)statusCode{
/*
    This delegate only updates if you've called "startTrackingDriversPosition"
    AND the drivers position has been updated
*/
    
    [geekHelper moveDriverPin:currentCoords mapview:mainMap];
    
    if (statusCode == 1) { // A driver has accepted the ride
        [waterview updateETA:geekHelper->originPinPoint.coordinate currentDriverCoords:geekHelper->driverPinPoint.coordinate];
    }else if(statusCode == 4){ // Driver has picked up user and is on route to destination
        [waterview updateETA:geekHelper->destinationPoint.coordinate currentDriverCoords:geekHelper->driverPinPoint.coordinate];
    }
}




/*
 //////////////////////////////////////////////////////////////////////////////////////////////////
                                            Driver Mode
 //////////////////////////////////////////////////////////////////////////////////////////////////
*/
#pragma mark - Initializing Driver Mode Method
-(void)initializeDriverMode{
    if (driverMode == YES) {
        // Switch back to User Mode
        addLoading(@"Going offline..");
        
        // Mark driver as Offline
        [GeekNavi driverOnline:NO block:^(id JSON, WebServiceResult geekResult) {
            if (geekResult==WebServiceResultSuccess) {
                [mainMap setShowsUserLocation:NO];
                
                driverMode = NO;
                [fromAddressView setHidden:NO];
                [navigationButton setHidden:NO];
                [setPickUpButton setHidden:NO];
                [mainMap addGestureRecognizer:tapToMovePin];
                
                UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
                [btnRight setFrame:CGRectMake(0, 0, 35, 35)];
                [btnRight setImage:[UIImage imageNamed:@"notactive_steeringwheel.png"] forState:UIControlStateNormal];
                [btnRight addTarget:self action:@selector(initializeDriverMode) forControlEvents:UIControlEventTouchUpInside];
                
                UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
                [barBtnRight setTintColor:[UIColor whiteColor]];
                
                UINavigationItem *item = [self.navigationController.navigationBar.items objectAtIndex:0];
                item.rightBarButtonItem = barBtnRight;
                
                [self backToStartingPoint];
                removeLoading();
            }
        }];
        
    }else{
        // Switch to Driver Mode
        addLoading(@"Going online..");
        
        // Mark driver as Online
        [GeekNavi driverOnline:YES block:^(id JSON, WebServiceResult geekResult) {
            if (geekResult==WebServiceResultSuccess) {
                [waterview removeFromSuperview];
                [backButton removeFromSuperview];
                [bookingTint removeFromSuperview];
                
                [vehicleTypeList removeFromSuperview];
                [fromAddressView setHidden:YES];
                [navigationButton setHidden:YES];
                [setPickUpButton setHidden:YES];
                driverMode = YES;
                
                [mainMap removeGestureRecognizer:tapToMovePin];
                
                [geekHelper removeAllPins:mainMap];
                [geekHelper removeLinesFromMap:mainMap];
                [mainMap setShowsUserLocation:YES];
                [mainMap setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
                
                UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
                [btnRight setFrame:CGRectMake(0, 0, 35, 35)];
                [btnRight setImage:[UIImage imageNamed:@"steeringwheel.png"] forState:UIControlStateNormal];
                [btnRight addTarget:self action:@selector(initializeDriverMode) forControlEvents:UIControlEventTouchUpInside];
                
                UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
                [barBtnRight setTintColor:[UIColor whiteColor]];
                
                UINavigationItem *item = [self.navigationController.navigationBar.items objectAtIndex:0];
                item.rightBarButtonItem = barBtnRight;
                [geekHelper startLookingForRides];
                removeLoading();
            }
        }];
    }
}

#pragma mark - Fetching the available rides for the driver
-(void)fetchedAvailableRidesForDriver:(NSDictionary *)info{
    if (info.count > 0) { // If there's a new ride available
        [geekHelper stopLookingForRides]; // Then stop looking for new rides
        
        AudioServicesPlaySystemSound(1007);
        
        currentRideID = [info[@"iFeedID"] intValue];
        
        [GeekNavi getUserInformationFromUserID:[info[@"iUserID"] intValue] block:^(id JSON, WebServiceResult geekResult) {
            if (geekResult==WebServiceResultSuccess) {
                newRideView = [[GeekWaterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-225, self.view.frame.size.width, 225)];
                newRideView.watercolor = [UIColor whiteColor];
                [newRideView displayNewRideWithInfo:[NSString stringWithFormat:@"%@ %@",JSON[@"data"][@"vFirst"],JSON[@"data"][@"vLast"]] distance:[NSString stringWithFormat:@"%.2f miles",[info[@"distance"] doubleValue]] userPhoneNumber:JSON[@"data"][@"userPhone"] userProfileImage:JSON[@"data"][@"vImage"]];
                
                
                [self.view addSubview:newRideView];
                
                [geekHelper addOriginPin:CLLocationCoordinate2DMake([info[@"fLat"] doubleValue], [info[@"fLong"] doubleValue]) mapview:mainMap];
                [geekHelper setOriginPin:mainMap withAddress:info[@"fAddress"]];
                
                [geekHelper addDestinationPin:CLLocationCoordinate2DMake([info[@"toLat"] doubleValue], [info[@"toLong"] doubleValue]) mapview:mainMap];
                
                [geekHelper setDestinationPoint:mainMap withAddress:info[@"tAddress"]];
                
                [geekHelper zoomToFitMapAnnotations:mainMap];
            }
        }];
    }
}

#pragma mark - Deny the incoming request
-(IBAction)denyRideRequest:(id)sender{
    [newRideView removeFromSuperview];
    [geekHelper removeAllPins:mainMap];
    [geekHelper startLookingForRides];
}

#pragma mark - Accept the incoming request
-(IBAction)acceptRideRequest:(id)sender{
    [GeekNavi acceptRide:currentRideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            [mainMap removeAnnotation:geekHelper->destinationPoint];
            [mainMap selectAnnotation:geekHelper->originPinPoint animated:YES];
            [newRideView appendOnRouteInfo];
            
            [geekHelper startTrackingUserCancellationWithRideID:currentRideID];
            [geekHelper startBroadcastingLocationToUserWithRideID:currentRideID];
            
            self.navigationController.navigationBar.hidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            if(![driverNavigateButton isDescendantOfView:self.view]){
                driverNavigateButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 8, self.view.frame.size.width/2-16, 50)];
                [driverNavigateButton setBackgroundColor:THEME_COLOR];
                [driverNavigateButton setTitle:@"Navigate" forState:UIControlStateNormal];
                [driverNavigateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                driverNavigateButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:25.0f];
                [driverNavigateButton addTarget:self action:@selector(navigateToPin:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:driverNavigateButton];
            }
            
            if(![driverArrivedButton isDescendantOfView:self.view]){
                driverArrivedButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2+8, 8, self.view.frame.size.width/2-16, 50)];
                [driverArrivedButton setBackgroundColor:[UIColor whiteColor]];
                [driverArrivedButton setTitle:@"Arrived" forState:UIControlStateNormal];
                [driverArrivedButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
                driverArrivedButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:25.0f];
                [driverArrivedButton addTarget:self action:@selector(arrivedAction:) forControlEvents:UIControlEventTouchUpInside];
                driverArrivedButton.layer.borderColor = THEME_COLOR.CGColor;
                driverArrivedButton.layer.borderWidth = 1.0f;
                [self.view addSubview:driverArrivedButton];
            }
        }else{
            showAlertViewWithMessage(@"Someone else accepted this Ride before you!");
            [self denyRideRequest:nil];
        }
    }];
}

#pragma mark - User canceled ride delegate
-(void)userCanceledDelegate{
    showAlertViewWithMessage(@"The Ride has been canceled");
    [driverArrivedButton removeFromSuperview];
    [driverNavigateButton removeFromSuperview];
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [geekHelper stopBroadcastingLocationToUser];
    [geekHelper stopTrackingUserCancellation];
    [self denyRideRequest:nil];
}

#pragma mark - Arrived to user's pickup location action
-(IBAction)arrivedAction:(id)sender{
    [GeekNavi markAsArrived:currentRideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            
            /*
             
             (Optional) Sends a text message to the user that requested the ride with the message "Your driver has arrived!"
             
            [GeekNavi sendTextMessageToUserFromRideID:currentRideID message:@"Your driver has arrived!" block:^(id JSON, WebServiceResult geekResult) {
                if (geekResult==WebServiceResultSuccess) {
                    //
                }
            }];
             
            */
            
            
            [mainMap removeAnnotation:geekHelper->originPinPoint];
            
            [mainMap addAnnotation:geekHelper->destinationPoint];
            [mainMap selectAnnotation:geekHelper->destinationPoint animated:YES];
            
            [geekHelper getCurrentLocation:^(float latitude, float longitude, CLLocation *location) {
                [geekHelper calculateDistanceBetweenCoords:location.coordinate toCoords:geekHelper->destinationPoint.coordinate block:^(double miles) {
                    [newRideView updateDistanceLabel:[NSString stringWithFormat:@"%.2f miles",miles]];
                }];
            } locationAddress:nil];
            
            [driverArrivedButton setTitle:@"Complete" forState:UIControlStateNormal];
            [driverArrivedButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            
            [driverArrivedButton addTarget:self action:@selector(completeRideAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

#pragma mark - Ride Complete action
-(IBAction)completeRideAction:(id)sender{
    // This method checks if the driver is within 0.1 mile of the destination and returns the result in a block
    [geekHelper getCurrentLocation:^(float latitude, float longitude, CLLocation *location) {
        [geekHelper calculateDistanceBetweenCoords:location.coordinate toCoords:geekHelper->destinationPoint.coordinate block:^(double miles) {
            if (miles > 0.1) { // More than 0.1 mile away!.. Let's ask the driver if he's sure that he wants to mark it as 'complete'
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                message:@"You're really far away from the destination.. Are you sure you want to mark it as 'complete'?"
                                                               delegate:self
                                                      cancelButtonTitle:@"No"
                                                      otherButtonTitles:@"Yes", nil];
                [alert show];
            }else{
                [self completeRide];
            }
        }];
    } locationAddress:nil];
}

#pragma mark - Navigate to Pin action
-(IBAction)navigateToPin:(id)sender{
    for (id obj in [mainMap annotations]) {
        if (obj == geekHelper->originPinPoint) {
            [geekHelper getCurrentLocation:^(float latitude, float longitude, CLLocation *location) {
                NSString *urlString = [NSString stringWithFormat:@"https://maps.apple.com/?daddr=%f,%f&saddr=%f,%f",geekHelper->originPinPoint.coordinate.latitude,geekHelper->originPinPoint.coordinate.longitude,latitude,longitude];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            } locationAddress:nil];
            break;
        }else if(obj == geekHelper->destinationPoint){
            [geekHelper getCurrentLocation:^(float latitude, float longitude, CLLocation *location) {
                NSString *urlString = [NSString stringWithFormat:@"https://maps.apple.com/?daddr=%f,%f&saddr=%f,%f",geekHelper->destinationPoint.coordinate.latitude,geekHelper->destinationPoint.coordinate.longitude,latitude,longitude];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            } locationAddress:nil];
            break;
        }
    }
}

#pragma mark - Driver Cancel action
-(IBAction)driverCancelRequest:(id)sender{
    [GeekNavi cancelRideWithRideID:currentRideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            [mainMap removeAnnotations:@[geekHelper->destinationPoint,geekHelper->originPinPoint]];
            [newRideView removeFromSuperview];
            [geekHelper stopBroadcastingLocationToUser];
            [geekHelper stopTrackingUserCancellation];
            self.navigationController.navigationBar.hidden = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [geekHelper startLookingForRides];
        }
    }];
}

#pragma mark - Complete Ride method
-(void)completeRide{
    [GeekNavi completeRide:currentRideID block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            [driverNavigateButton removeFromSuperview];
            [driverArrivedButton removeFromSuperview];
            [newRideView removeFromSuperview];
            [mainMap removeAnnotations:@[geekHelper->destinationPoint,geekHelper->originPinPoint]];
            [geekHelper stopBroadcastingLocationToUser];
            [geekHelper stopTrackingUserCancellation];
            [self performSegueWithIdentifier:@"driverRideComplete" sender:nil];
        }
    }];
}

#pragma mark - Alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(buttonIndex) {
        case 0: //"No" pressed
            break;
        case 1: //"Yes" pressed
            [self completeRide];
            break;
    }
}






/*
 //////////////////////////////////////////////////////////////////////////////////////////////////
                                General User Interface Methods/Delegates
 //////////////////////////////////////////////////////////////////////////////////////////////////
*/

#pragma mark - MKAnnotation Mapview
- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation{
    if (annotation == mapview.userLocation) {
        static NSString * const identifier = @"DriverPinPointIdentifier";
        
        MKAnnotationView *annotationView = [mapview dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView){
            annotationView.annotation = annotation;
        }else{
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:identifier];
        }
        
        annotationView.canShowCallout = NO;
        annotationView.image = [UIImage imageNamed:@"carMarker.png"];
        
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[geekHelper->originPinPoint class]]){
        static NSString * const identifier = @"OriginPointIdentifier";
        
        MKAnnotationView *annotationView = [mapview dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView){
            annotationView.annotation = annotation;
        }else{
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:identifier];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"fromMarker.png"];
        
        return annotationView;
    }else if ([annotation isKindOfClass:[geekHelper->destinationPoint class]]){
        static NSString * const identifier = @"DestinationPointIdentifier";
        
        MKAnnotationView *annotationView = [mapview dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView){
            annotationView.annotation = annotation;
        }else{
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:identifier];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"toMarker.png"];
        
        return annotationView;
    }else if ([annotation isKindOfClass:[geekHelper->driverPinPoint class]]){
        static NSString * const identifier = @"DriverPinPointIdentifier";
        
        MKAnnotationView *annotationView = [mapview dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView){
            annotationView.annotation = annotation;
        }else{
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:identifier];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"carMarker.png"];
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - MKMapview Lines
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = THEME_COLOR;
    renderer.lineWidth = 3.0;
    return renderer;
}

#pragma mark - Textfield Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    fromAddressConstantY.constant = fromAddressView.frame.origin.y - vehicleTypeList.frame.size.height - 64 - 8;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [geekHelper getCoordinatesFromAddress:textField.text returnBlock:^(CLLocationCoordinate2D coordinates, BOOL success) {
        if (success) {
            [geekHelper moveActivePin:coordinates mapview:mainMap];
            [geekHelper zoomToCoordinate:coordinates withMap:mainMap animated:YES];
        }
    } returnedAddress:^(NSString *address) {
        if (address) {
            textField.text = address;
        }
    }];
    
    fromAddressConstantY.constant = 10;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Selection List
-(void)drawSelectors{
    if(![vehicleTypeList isDescendantOfView:self.view]){
        vehicleTypeList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        vehicleTypeList.delegate = self;
        vehicleTypeList.dataSource = self;
        [vehicleTypeList setCenterButtons:YES];
        [vehicleTypeList setSelectionIndicatorHorizontalPadding:(self.view.frame.size.width/3)/3];
        [vehicleTypeList setSelectionIndicatorHeight:3.0f];
        [vehicleTypeList setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:18.0f] forState:UIControlStateNormal];
        [vehicleTypeList setTitleFont:[UIFont fontWithName:@"AvenirNext-Medium" size:23.0f] forState:UIControlStateSelected];
        [vehicleTypeList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [vehicleTypeList setSelectionIndicatorColor:[UIColor whiteColor]];
        [vehicleTypeList setSelectionIndicatorStyle:HTHorizontalSelectionIndicatorStyleBottomBar];
        [vehicleTypeList setBackgroundColor:THEME_COLOR];
        [self.view addSubview:vehicleTypeList];
        
        [UIView animateWithDuration:.4 animations:^{
            [vehicleTypeList setFrame:CGRectMake(0, 64, self.view.frame.size.width, 64)];
        }];
    }
}
-(void)drawBackbutton{
    if(![backButton isDescendantOfView:self.view]){
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 64 + 8, 50, 50)];
        [backButton setImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backButton];
    }
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods
- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    vehicleType = (int)index;
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods
- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return selectionListArray.count;
}
- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    return selectionListArray[index];
}

#pragma mark - Tap Gesture (Move pin to point where tapped)
- (void)tapGestureHandler:(UITapGestureRecognizer *)tgr{
    CLLocationCoordinate2D touchMapCoordinate = [mainMap convertPoint:[tgr locationInView:mainMap] toCoordinateFromView:mainMap];
    
    [geekHelper moveActivePin:touchMapCoordinate mapview:mainMap];
    
    [geekHelper getAddressFromCoordinates:touchMapCoordinate returnBlock:^(NSString *address, BOOL success) {
        if (success) {
            fromAddressTextField.text = address;
        }
    }];
}

#pragma mark - Customize Screen Method
-(void)customizeScreen{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    fromAddressTextField.leftView = paddingView;
    fromAddressTextField.leftViewMode = UITextFieldViewModeAlways;
    setPickUpButton.layer.cornerRadius = 10.0f;
    fromAddressView.layer.cornerRadius = 10.0f;
    mainMap.showsCompass = NO;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                              NSFontAttributeName: [UIFont fontWithName:@"Avenir-Light" size:22.0f]
                              }];
    
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 35, 35)];
    if ([userInformation[@"vDriverorNot"] isEqualToString:@"driver"]) {
        // User is a driver
        [btnRight setImage:[UIImage imageNamed:@"notactive_steeringwheel.png"] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(initializeDriverMode) forControlEvents:UIControlEventTouchUpInside];
    }else{
        // User is not a driver
        [btnRight setImage:[UIImage imageNamed:@"presenticon.png"] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(giftIconAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    [barBtnRight setTintColor:[UIColor whiteColor]];
    
    UINavigationItem *item = [self.navigationController.navigationBar.items objectAtIndex:0];
    item.rightBarButtonItem = barBtnRight;
}
-(void)addObservers{
    // User Observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelAction:)
                                                 name:@"cancelNotification"
                                               object:nil];
    
    
    // Driver Observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(acceptRideRequest:)
                                                 name:@"acceptRideNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(denyRideRequest:)
                                                 name:@"denyRideNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(driverCancelRequest:)
                                                 name:@"driverCancelNotification"
                                               object:nil];
}

#pragma mark - Loading the exited state method
-(void)loadExitedStage{
    [GeekNavi getActiveRideInfo:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            if (JSON[@"data"]) { // Has previous state
                
                NSLog(@"JSON::: %@",JSON);
                
                addLoading(@"Loading previous Ride..");
                
                [mainMap removeGestureRecognizer:tapToMovePin];
                [vehicleTypeList removeFromSuperview];
                [fromAddressView setHidden:YES];
                [navigationButton setHidden:YES];
                [setPickUpButton setHidden:YES];
                
                self.navigationController.navigationBar.hidden = YES;
                [[UIApplication sharedApplication] setStatusBarHidden:YES];
                
                [priceView removeFromSuperview];
                [backButton removeFromSuperview];
                waterview = [[GeekWaterView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-225, self.view.frame.size.width, 225)];
                waterview.watercolor = [UIColor whiteColor];
                
                [geekHelper moveActivePin:CLLocationCoordinate2DMake([JSON[@"data"][0][@"fLat"] doubleValue], [JSON[@"data"][0][@"fLong"] doubleValue]) mapview:mainMap];
                [geekHelper addDestinationPin:CLLocationCoordinate2DMake([JSON[@"data"][0][@"toLat"] doubleValue], [JSON[@"data"][0][@"toLong"] doubleValue]) mapview:mainMap];
                currentRideID = [JSON[@"data"][0][@"iFeedID"] intValue];
                [geekHelper startTrackingRideUpdatesWithRideID:currentRideID];
                
                if(![waterview isDescendantOfView:self.view]){
                    [self.view addSubview:waterview];
                }
                removeLoading();
            }
        }
    }];
}

#pragma mark - Checking the state of the driver application method
-(void)checkApplicationState{
    if (![userInformation[@"vDriverorNot"] isEqualToString:@"driver"]) {
        // Get the state of the driver application
        [GeekNavi getApplicationState:^(id JSON, WebServiceResult geekResult) {
            if (geekResult==WebServiceResultSuccess) {
                if (![JSON[@"data"] isKindOfClass:[NSNull class]]) {
                    if ([JSON[@"data"]isEqualToString:@"insurance"] || [JSON[@"data"]isEqualToString:@"registration"] || [JSON[@"data"]isEqualToString:@"carpicture"] || [JSON[@"data"]isEqualToString:@"picture"]) {
                        applicationInfo = JSON[@"data"];
                        [self performSegueWithIdentifier:@"moreInfoSegue" sender:nil];
                    }
                }
            }
        }];
    }
}

#pragma mark - Back to the starting point method
-(void)backToStartingPoint{
    [waterview removeFromSuperview];
    [backButton removeFromSuperview];
    [bookingTint removeFromSuperview];
    
    [geekHelper removeAllPins:mainMap];
    [geekHelper removeLinesFromMap:mainMap];
    
    [self drawSelectors];
    [self getLocationAndAddPin];
    [fromAddressView setHidden:NO];
    [navigationButton setHidden:NO];
    [setPickUpButton setHidden:NO];
    [setPickUpButton setAlpha:1.0f];
    
    [mainMap addGestureRecognizer:tapToMovePin];
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [setPickUpButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [setPickUpButton addTarget:self action:@selector(setPickupAction:) forControlEvents:UIControlEventTouchUpInside];
    fromAddressTextField.placeholder = NSLocalizedString(@"from_address", nil);
    fromLabel.text = NSLocalizedString(@"from", nil);
    [setPickUpButton setTitle:NSLocalizedString(@"set_pickup", nil) forState:UIControlStateNormal];
    [setPickUpButton setBackgroundColor:[UIColor colorWithRed:66.0/255.0 green:75.0/255.0 blue:83.0/255.0 alpha:1.0]];
    
    [geekHelper stopTrackingRideUpdates];
    [geekHelper stopTrackingDriversPosition];
}

#pragma mark - Prepare for Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"driverRideComplete"]) {
        DriverRideCompleteViewController *vc = (DriverRideCompleteViewController *)[segue destinationViewController];
        vc.rideID = currentRideID;
    }else if ([[segue identifier] isEqualToString:@"completeRideSegue"]) {
        SEReceiptVC *vc = (SEReceiptVC *)[segue destinationViewController];
        vc.rideID = currentRideID;
    }else if([[segue identifier] isEqualToString:@"moreInfoSegue"]){
        SEMoreInfoApplication *vc = (SEMoreInfoApplication *)[segue destinationViewController];
        vc.needInfoString = applicationInfo;
    }
}

#pragma mark - Unwind to Main View Controller (From: Driver Ride Complete View Controller)
-(IBAction)unwindToMainViewController:(UIStoryboardSegue *)unwindSegue{
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [geekHelper startLookingForRides];
}

@end
