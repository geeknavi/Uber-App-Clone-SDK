//
//  ApplyToDriveViewController.m
//  GeekNavi
//
//  Created by GeekNavi on 11/28/16.
//  Copyright © 2016 GeekNavi. All rights reserved.
//

#import "ApplyToDriveViewController.h"
#import "REFormattedNumberField.h"
#import <GeekNavi/GeekDrawCamera.h>
#import "GeekApplicant.h"
#import <GeekNavi/GeekPhotoLibrary.h>

#define MAX_STEPS 11
#define BETWEEN(value, min, max) (value < max && value > min)

typedef enum : NSUInteger {
    // General Details
    zipCode,
    
    // User Specific Details
    fullName,
    socialSecurityNumber,
    dateOfBirth,
    driverLicenseNumber,
    profilePicture,
    
    // Vehicle Specific Details
    pictureOfVehicle,
    pictureOfRegistration,
    pictureOfInsurance,
    licensePlateNumber,
    typeOfVehicle,
} applicantDetailInfo;

static float defaultConstraintValue = 0.0f;
static BOOL skipAsking = NO;
@interface ApplyToDriveViewController () <UIActionSheetDelegate,GeekPhotoLibraryDelegate>{
    // UIButtons
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIButton *nextButton;
    
    // UILabels
    __weak IBOutlet UILabel *questionLabel;
    __weak IBOutlet UILabel *currentStepLabel;
    
    // UITextFields
    __weak IBOutlet REFormattedNumberField *userInputTextField;
    
    // UIViews
    __weak IBOutlet UIView *separatorView;
    UIView *imageEditingView;
    UIView *cameraAddView;
    
    // UIImageView
    UIImageView *userInputImageView;
    
    // Constraints
    __weak IBOutlet NSLayoutConstraint *xConstantConstraint;
    __weak IBOutlet NSLayoutConstraint *backButtonYConstraint;
    __weak IBOutlet NSLayoutConstraint *nextButtonYConstraint;
    
    // Applicant
    GeekApplicant *applicant;
}

@end

@implementation ApplyToDriveViewController
@synthesize referralCode,selectedCity;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // First, allocate the applicant
    applicant = [[GeekApplicant alloc] init];
    
    // As always, start with customizing the screen (MAIN/SUB Colors)
    [self customizeScreen];
    
    // Set the default value
    defaultConstraintValue = xConstantConstraint.constant;
    
    // Sign up for keyboard notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
    
    // Pass info from segue
    applicant.selectedCity = selectedCity;
    applicant.referralCode = referralCode;
    
    // Set delegate
    [GeekPhotoLibrary sharedInstance].delegate = self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Add temporary loader
    addLoading(@"");
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Get step
    int step = applicant.currentStep;
    
    // Ask for the first step
    if (skipAsking == NO) {
        [self askUserFor:step];
    }else{
        skipAsking = NO;
    }
    
    // Unhide back button if step isn't 0
    if (step != 0) {
        // Fade in; if it's hidden
        if (backButton.alpha == 0){
            [UIView animateWithDuration:.4 animations:^{
                backButton.alpha = 1.0f;
            }];
        }
    }
    
    // Remove Loading
    removeLoading();
}
#pragma mark - Exit Action
- (IBAction)exitAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Back Action
- (IBAction)backAction:(id)sender {
    // Decrement step
    applicant.currentStep--;
    
    // Ask for the next step
    [self askUserFor:applicant.currentStep];
    
    // Check if its 0 now
    if (applicant.currentStep == 0) {
        // Fade out if so
        [UIView animateWithDuration:.4 animations:^{
            backButton.alpha = 0.0f;
        }];
    }
    
    // Reset color if needed
    if (nextButton.backgroundColor != SUB_THEME_COLOR) {
        nextButton.backgroundColor = SUB_THEME_COLOR;
    }
}

#pragma mark - Next Action
- (IBAction)nextAction:(id)sender {
    // Show warning if the length is 0
    if (userInputTextField.text.length == 0 && !userInputTextField.isHidden) {
        showAlertViewWithTitleAndMessage(NSLocalizedString(@"missing_field", nil), NSLocalizedString(@"application_required_field", nil));
        return;
    }
    
    // Fade in; if it's hidden
    if (backButton.alpha == 0){
        [UIView animateWithDuration:.4 animations:^{
            backButton.alpha = 1.0f;
        }];
    }
    
    // Get the current step
    int currentStep = applicant.currentStep;
    
    // Pop alert if the user is missing an image
    if (userInputImageView.image == nil && BETWEEN((currentStep + 1), 6, 10)) {
        showAlertViewWithTitleAndMessage(@"Missing Image", NSLocalizedString(@"missing_image", nil));
        return;
    }
    
    // Add information to applicant
    if (currentStep == zipCode) {
        applicant.zipCode = userInputTextField.text;
    }
    
    // User Specific Details
    else if (currentStep == fullName){
        applicant.fullName = userInputTextField.text;
    }else if (currentStep == socialSecurityNumber){
        applicant.socialSecurityNumber = (int)userInputTextField.text;
    }else if (currentStep == dateOfBirth){
        applicant.dateOfBirth = userInputTextField.text;
    }else if (currentStep == driverLicenseNumber){
        applicant.driverLicenseNumber = userInputTextField.text;
    }else if (currentStep == profilePicture){
        applicant.profilePicture = userInputImageView.image;
    }
    
    // Vehicle Specific Details
    else if (currentStep == pictureOfVehicle){
        applicant.pictureOfVehicle = userInputImageView.image;
    }else if (currentStep == pictureOfRegistration){
        applicant.pictureOfRegistration = userInputImageView.image;
    }else if (currentStep == pictureOfInsurance){
        applicant.pictureOfInsurance = userInputImageView.image;
    }else if (currentStep == licensePlateNumber){
        applicant.licensePlateNumber = userInputTextField.text;
    }else if (currentStep == typeOfVehicle){
        applicant.typeOfVehicle = userInputTextField.text;
    }
    
    // Mark as green if equal to last step
    if ((currentStep + 1) == (MAX_STEPS - 1)) {
        [nextButton setBackgroundColor:[UIColor colorWithRed:105.0/255.0f green:188.0/255.0f blue:69.0/255.0f alpha:1.0f]];
    }
    
    // Submit application
    if ((currentStep + 1) >= MAX_STEPS) {
        addLoading(@"");
        [applicant applyWithResultBlock:^(id JSON, WebServiceResult geekResult) {
            // Reset application
            [applicant resetApplication];
            
            if (geekResult == WebServiceResultSuccess) {
                [self dismissViewControllerAnimated:YES completion:^{
                    showAlertViewWithTitleAndMessage(@"Success!", NSLocalizedString(@"application_complete", nil));
                }];
            }else{
                [self dismissViewControllerAnimated:YES completion:^{
                    showAlertViewWithTitleAndMessage(nil, NSLocalizedString(@"application_internet_fail", nil));
                }];
            }
        }];
        
        return;
    }
    
    // Increment step
    applicant.currentStep++;
    
    // Ask for the next step
    [self askUserFor:applicant.currentStep];
}

#pragma mark - Ask User Method
-(void)askUserFor:(applicantDetailInfo)detail{
    // Reset Image
    userInputImageView.image = nil;
    
    // Update step on UILabel
    currentStepLabel.text = [NSString stringWithFormat:@"%d/11",applicant.currentStep+1];
    
    // Clear out textfield
    userInputTextField.text = @"";
    
    // Animate out
    xConstantConstraint.constant = -self.view.frame.size.width;
    [UIView animateWithDuration:.4 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        // No matter what, remove the images first
        [self removeTakeNewImage];
        
        // ### General Details
        if(detail == zipCode){
            questionLabel.text = NSLocalizedString(@"what_is_your_zip_code", nil);
            userInputTextField.placeholder = @"12345";
            userInputTextField.text = applicant.zipCode;
            userInputTextField.format = nil;
            userInputTextField.formatEnabled = NO;
            userInputTextField.keyboardType = UIKeyboardTypeNumberPad;
            [userInputTextField reloadInputViews];
            [userInputTextField becomeFirstResponder];
            separatorView.hidden = NO;
            userInputTextField.hidden = NO;
        }
        
        // ### User Specific Details
        else if(detail == fullName){
            questionLabel.text = NSLocalizedString(@"what_is_your_name", nil);
            [self prepareTextFieldWithPlaceholder:@"John Doe" andText:applicant.fullName andKeyboardType:UIKeyboardTypeASCIICapable andFormat:nil formatEnabled:NO];
        }else if(detail == socialSecurityNumber){
            questionLabel.text = NSLocalizedString(@"what_is_your_ssn", nil);
            NSString *text = nil;
            if (applicant.socialSecurityNumber != 0) {
                text = [NSString stringWithFormat:@"%d",applicant.socialSecurityNumber];
            }
            
            [self prepareTextFieldWithPlaceholder:@"123-45-6789" andText:text andKeyboardType:UIKeyboardTypeNumberPad andFormat:@"XXX-XX-XXXX" formatEnabled:YES];
        }else if(detail == dateOfBirth){
            questionLabel.text = NSLocalizedString(@"what_is_your_dob", nil);
            [self prepareTextFieldWithPlaceholder:@"01-01-1990" andText:applicant.dateOfBirth andKeyboardType:UIKeyboardTypeNumberPad andFormat:@"XX-XX-XXXX" formatEnabled:YES];
        }else if(detail == driverLicenseNumber){
            questionLabel.text = NSLocalizedString(@"what_is_your_dl_number", nil);
            [self prepareTextFieldWithPlaceholder:@"123456789" andText:applicant.driverLicenseNumber andKeyboardType:UIKeyboardTypeNumberPad andFormat:nil formatEnabled:NO];
        }else if(detail == profilePicture){
            questionLabel.text = NSLocalizedString(@"is_this_correct_picture", nil);
            userInputTextField.placeholder = @"";
            userInputTextField.format = nil;
            userInputTextField.formatEnabled = NO;
            
            // Hide keyboard
            [userInputTextField resignFirstResponder];
            
            // Hide textfield & separator
            userInputTextField.hidden = YES;
            separatorView.hidden = YES;
            
            // Show the profile image
            UIImage *profileImage = applicant.profilePicture;
            if (profileImage == nil) {
                NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userInformation[@"profileImage"][@"original"]]];
                if (data){
                    profileImage = [UIImage imageWithData:data];
                }else{
                    profileImage = [UIImage imageNamed:@"logo.png"];
                }
            }
            
            [self showImageAndEditableLabel:profileImage];
        }
        
        // ### Vehicle Specific Details
        else if(detail == pictureOfVehicle){
            // Hide keyboard
            [userInputTextField resignFirstResponder];
            
            // Change the text
            questionLabel.text = NSLocalizedString(@"attach_vehicle_picture", nil);
            
            // Hide textfield & separator
            userInputTextField.hidden = YES;
            separatorView.hidden = YES;
            
            if (applicant.pictureOfVehicle == nil) {
                [self takeNewImage];
            }else{
                // Show image & edit label
                [self showImageAndEditableLabel:applicant.pictureOfVehicle];
            }
        }else if(detail == pictureOfRegistration){
            // Hide keyboard
            [userInputTextField resignFirstResponder];
            
            // Change the text
            questionLabel.text = NSLocalizedString(@"attach_vehicle_registration_picture", nil);
            
            // Hide textfield & separator
            userInputTextField.hidden = YES;
            separatorView.hidden = YES;
            
            if (applicant.pictureOfRegistration == nil) {
                [self takeNewImage];
            }else{
                // Show image & edit label
                [self showImageAndEditableLabel:applicant.pictureOfRegistration];
            }
        }else if(detail == pictureOfInsurance){
            // Hide keyboard
            [userInputTextField resignFirstResponder];
            
            // Change the text
            questionLabel.text = NSLocalizedString(@"attach_vehicle_insurance_picture", nil);
            
            // Hide textfield & separator
            userInputTextField.hidden = YES;
            separatorView.hidden = YES;
            
            if (applicant.pictureOfInsurance == nil) {
                [self takeNewImage];
            }else{
                // Show image & edit label
                [self showImageAndEditableLabel:applicant.pictureOfInsurance];
            }
        }else if(detail == licensePlateNumber){
            questionLabel.text = NSLocalizedString(@"vehicle_license_plate_number", nil);
            [self prepareTextFieldWithPlaceholder:@"ABC 123" andText:applicant.licensePlateNumber andKeyboardType:UIKeyboardTypeASCIICapable andFormat:nil formatEnabled:NO];
        }else if(detail == typeOfVehicle){
            questionLabel.text = NSLocalizedString(@"type_of_vehicle", nil);
            [self prepareTextFieldWithPlaceholder:@"Black 2016 Honda Civic" andText:applicant.typeOfVehicle andKeyboardType:UIKeyboardTypeASCIICapable andFormat:nil formatEnabled:NO];
        }
        
        // Place on the other side
        xConstantConstraint.constant = self.view.frame.size.width;
        [self.view layoutIfNeeded];
        
        // Animate back to original
        xConstantConstraint.constant = defaultConstraintValue;
        [UIView animateWithDuration:.4 animations:^{
            [self.view layoutIfNeeded];
        }];
        
    }];
}

#pragma mark - Prepare textfield for text input
-(void)prepareTextFieldWithPlaceholder:(NSString *)placeholder andText:(NSString *__nullable)text andKeyboardType:(UIKeyboardType)keyboardType andFormat:(NSString *__nullable)format formatEnabled:(BOOL)formatEnabled{
    userInputTextField.placeholder = placeholder;
    
    if (text != nil) {
        userInputTextField.text = text;
    }else{
        userInputTextField.text = @"";
    }
    
    userInputTextField.format = format;
    userInputTextField.formatEnabled = formatEnabled;
    userInputTextField.keyboardType = keyboardType;
    [userInputTextField reloadInputViews];
    [userInputTextField becomeFirstResponder];
    separatorView.hidden = NO;
    userInputTextField.hidden = NO;
}
-(void)editImage{
    // Pop up (Camera / Photo Album)
    UIActionSheet *sheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"take_new_picture", nil),NSLocalizedString(@"use_existing_picture", nil), nil];
    [sheet showInView:self.view];
}

#pragma mark - Take new image
-(void)takeNewImage{
    // Make sure we got correct values
    [self.view layoutIfNeeded];
    
    // Remove the view if it's there
    if ([imageEditingView isDescendantOfView:self.view]){
        [imageEditingView removeFromSuperview];
    }
    
    // Get the height of the label
    CGFloat height = [self getLabelHeight:questionLabel];
    
    // Allocate main view
    cameraAddView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-40, questionLabel.frame.origin.y+height+8, 80, 80)];
    
    // Camera Button
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [cameraButton setImage:[GeekDrawCamera imageOfCameraWithRect:CGRectMake(cameraAddView.center.x-39/2, cameraButton.center.y-31/2, 39, 31) color:[UIColor whiteColor]] forState:UIControlStateNormal];
    [cameraButton setBackgroundColor:[UIColor darkGrayColor]];
    [cameraButton addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
    
    cameraButton.layer.cornerRadius = cameraButton.frame.size.height/2;
    cameraButton.layer.masksToBounds = YES;
    
    // Add to camera view
    [cameraAddView addSubview:cameraButton];
    
    // Add to main view
    [self.view addSubview:cameraAddView];
}

#pragma mark - Show Image
-(void)showImageAndEditableLabel:(UIImage *)image{
    // Make sure we got correct values
    [self.view layoutIfNeeded];
    
    // Remove the camera view if there
    if ([cameraAddView isDescendantOfView:self.view]) {
        [cameraAddView removeFromSuperview];
    }
    
    // Get the height of the label
    CGFloat height = [self getLabelHeight:questionLabel];
    
    // Allocate main view
    imageEditingView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-50, questionLabel.frame.origin.y+height+8, 100, 125)];
    NSLog(@"Q y: %f",questionLabel.frame.origin.y);
    NSLog(@"Height: %f",height);
    NSLog(@"Total: %f",questionLabel.frame.origin.y+height+8);

    // Show profile image in center of screen
    userInputImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [userInputImageView setImage:image];
    userInputImageView.layer.cornerRadius = userInputImageView.frame.size.height/2;
    userInputImageView.layer.masksToBounds = YES;
    [imageEditingView addSubview:userInputImageView];
    
    // Show editable label under image
    UILabel *editableLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100+8, 100, 20)];
    editableLabel.text = @"Tap to Edit";
    editableLabel.textAlignment = NSTextAlignmentCenter;
    [imageEditingView addSubview:editableLabel];
    
    // Place a button over the whole view (to allow edit)
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 125)];
    [editButton addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
    
    // Add to main view
    [imageEditingView addSubview:editButton];
    [self.view addSubview:imageEditingView];
}

#pragma mark - Remove Take New Image
-(void)removeTakeNewImage{
    // IF it's there, remove it
    if ([imageEditingView isDescendantOfView:self.view]){
        [imageEditingView removeFromSuperview];
    }
    
    // Also remove camera icon if it's there
    if ([cameraAddView isDescendantOfView:self.view]) {
        [cameraAddView removeFromSuperview];
    }
}

#pragma mark - Keyboard Notifications
-(void)keyboardOnScreen:(NSNotification *)notification{
    NSDictionary *info  = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    // Bring up button above keyboard
    backButtonYConstraint.constant = keyboardFrame.size.height + 20;
    nextButtonYConstraint.constant = keyboardFrame.size.height + 20;
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
-(void)keyboardDidHide{
    backButtonYConstraint.constant = 20;
    nextButtonYConstraint.constant = 20;
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Dynamic Label Height
- (CGFloat)getLabelHeight:(UILabel*)label{
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

#pragma mark -Photo Delegate Method
-(void)geekPhotoLibraryReturnDelegate:(UIImage *)selectedPhoto{
    CGRect rect = CGRectMake(0,0,600,600);
    UIGraphicsBeginImageContext( rect.size );
    [selectedPhoto drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img = [UIImage imageWithData:imageData];
    
    if (![imageEditingView isDescendantOfView:self.view]){
        [self showImageAndEditableLabel:img];
    }else{
        [userInputImageView setImage:img];
    }
    
    if ([cameraAddView isDescendantOfView:self.view]) {
        [cameraAddView removeFromSuperview];
    }
}
#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"take_new_picture", nil)]){
        skipAsking = YES;
        [[GeekPhotoLibrary sharedInstance] takeNewPictureFromViewController:self];
    }else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"use_existing_picture", nil)]){
        skipAsking = YES;
        [[GeekPhotoLibrary sharedInstance] useExistingPictureFromViewController:self];
    }
}

#pragma mark - Customize Screen
-(void)customizeScreen{
    [self.view setBackgroundColor:MAIN_THEME_COLOR];
    [nextButton setBackgroundColor:SUB_THEME_COLOR];
    
    nextButton.layer.cornerRadius = nextButton.frame.size.height/2;
    nextButton.layer.masksToBounds = YES;
    
    backButton.layer.cornerRadius = nextButton.frame.size.height/2;
    backButton.layer.masksToBounds = YES;
}
@end
