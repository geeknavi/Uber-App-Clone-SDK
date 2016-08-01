#import "SEVehicleinformation.h"
#import "GeekPhotoLibrary.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface SEVehicleinformation () <GeekPhotoLibraryDelegate,UITextFieldDelegate>{
    BOOL vehiclepicture;
    BOOL vehicleinsurance;
    BOOL vehicleregistration;
    BOOL carpicturetaken;
    
    CGFloat animatedDistance;
    
    __weak IBOutlet UIImageView *pictureofcar;
    __weak IBOutlet UIImageView *InsurancePic;
    __weak IBOutlet UIImageView *RegistrationPic;
}
@property (weak, nonatomic) IBOutlet UITextField *registrationTextField;
@property (weak, nonatomic) IBOutlet UIView *topNavi;
@property (weak, nonatomic) IBOutlet UIButton *completeBtnReference;
@property (weak, nonatomic) IBOutlet UITextField *insuranceTextField;
@property (weak, nonatomic) IBOutlet UITextField *licenseplatenumbertextfield;
@property (weak, nonatomic) IBOutlet UITextField *typeofcartextfield;
@property (weak, nonatomic) IBOutlet UIView *licenseplateview;
@property (weak, nonatomic) IBOutlet UIView *vehicleInfo;
@property (weak, nonatomic) IBOutlet UIView *vehicleregview;
@property (weak, nonatomic) IBOutlet UIButton *changeCarImg;
@property (weak, nonatomic) IBOutlet UILabel *licenseplatenumbertext;
@property (weak, nonatomic) IBOutlet UILabel *typeofvehiclelabel;
@property (weak, nonatomic) IBOutlet UILabel *pictureofyourvehicleLabel;

@end

@implementation SEVehicleinformation
@synthesize selectedCity,referralCode,zipCode,licenseNumber,dateOfBirth,socialSecurityNumber,fullName;

- (void)viewDidLoad {
    [super viewDidLoad];
    [GeekPhotoLibrary sharedInstance].delegate=self;
    
    [self customizeScreenAndToolbars];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (IBAction)backBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)addvehiclepicture:(id)sender {
    vehiclepicture = YES;
    [[GeekPhotoLibrary sharedInstance]openPhotoFromCameraAndLibrary:self];
}
- (IBAction)addregistrationpic:(id)sender {
    vehicleregistration = YES;
    [[GeekPhotoLibrary sharedInstance]openPhotoFromCameraAndLibrary:self];
}
- (IBAction)addinsurancepic:(id)sender {
    vehicleinsurance = YES;
    [[GeekPhotoLibrary sharedInstance]openPhotoFromCameraAndLibrary:self];
}
-(void)geekPhotoLibraryReturnDelegate:(UIImage *)selectedPhoto{
    if (vehiclepicture == YES) {
        CGRect rect = CGRectMake(0,0,800,800);
        UIGraphicsBeginImageContext( rect.size );
        [selectedPhoto drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(picture1);
        UIImage *img=[UIImage imageWithData:imageData];
        [pictureofcar setImage:img];
        vehiclepicture = NO;
        carpicturetaken = YES;
    }
    if (vehicleregistration == YES) {
        CGRect rect = CGRectMake(0,0,800,800);
        UIGraphicsBeginImageContext( rect.size );
        [selectedPhoto drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(picture1);
        UIImage *img=[UIImage imageWithData:imageData];
        [RegistrationPic setImage:img];
        self.registrationTextField.backgroundColor = [UIColor colorWithRed:21.0/255.0 green:187.0/255.0 blue:24.0/255.0 alpha:1];
        
        self.registrationTextField.placeholder = @"Uploaded!";
        vehicleregistration = NO;
    }
    if (vehicleinsurance == YES) {
        CGRect rect = CGRectMake(0,0,800,800);
        UIGraphicsBeginImageContext( rect.size );
        [selectedPhoto drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(picture1);
        UIImage *img=[UIImage imageWithData:imageData];
        self.insuranceTextField.backgroundColor = [UIColor colorWithRed:21.0/255.0 green:187.0/255.0 blue:24.0/255.0 alpha:1];
        self.insuranceTextField.placeholder = @"Uploaded!";
        [InsurancePic setImage:img];
        vehicleinsurance = NO;
    }
}
-(void)beginUploadingImage:(NSString *)type image:(UIImage *)image block:(void(^)(BOOL success))callback{
    [GeekNavi uploadImage:type image:image block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            callback(YES);
        }else{
            callback(NO);
            if (JSON[@"message"]) {
                showAlertViewWithMessage(JSON[@"message"]);
            }else{
                removeLoading();
            }
        }
    }];
}

- (IBAction)completeBtn:(id)sender {
        if ([self.registrationTextField.placeholder isEqualToString:@"Picture of vehicle registration"]) {
                showAlertViewWithMessage(NSLocalizedString(@"application_registration_blank", nil));
        }else if ([self.insuranceTextField.placeholder isEqualToString:@"Picture of vehicle insurance"]){
            showAlertViewWithMessage(NSLocalizedString(@"application_insurance_blank", nil));
        }else if(self.licenseplatenumbertextfield.text.length == 0){
                showAlertViewWithMessage(NSLocalizedString(@"application_license_blank", nil));
        }else if(self.typeofcartextfield.text.length == 0){
                showAlertViewWithMessage(NSLocalizedString(@"application_vehicle_type_blank", nil));
        }else{
            
            addLoading(@"");
            [self beginUploadingImage:CARPICTURE image:pictureofcar.image block:^(BOOL success) {
                if (success) {
                    [self beginUploadingImage:INSURANCEPICTURE image:InsurancePic.image block:^(BOOL success) {
                        if (success) {
                            [self beginUploadingImage:REGISTRATIONPIC image:RegistrationPic.image block:^(BOOL success) {
                                if (success) {
                                    [GeekNavi finalizeApplication:@{
                                                                    @"fullname":fullName,
                                                                    @"SSN":socialSecurityNumber,
                                                                    @"DOB":dateOfBirth,
                                                                    @"licensenumber":licenseNumber,
                                                                    @"zipcode":zipCode,
                                                                    @"refferal":referralCode,
                                                                    @"city":selectedCity,
                                                                    @"status":@"pending",
                                                                    @"typeofcar":self.typeofcartextfield.text,
                                                                    @"platenumber":self.licenseplatenumbertextfield.text
                                                                    } block:^(id JSON, WebServiceResult geekResult) {
                                                                        if (geekResult==WebServiceResultSuccess) {
                                                                            removeLoading();
                                                                            [self performSegueWithIdentifier:@"popToRoot" sender:nil];
                                                                        }else if(geekResult==WebServiceResultFail){
                                                                            [self performSegueWithIdentifier:@"popToRoot" sender:nil];
                                                                            showAlertViewWithMessage(@"Couldn't apply at this point.. Try again later!");
                                                                        }
                                                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
}
#pragma mark - Tool bar actions
-(void)customizeScreenAndToolbars{
    UIToolbar*licenseplatedonetool = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    licenseplatedonetool.barStyle = UIBarStyleDefault;
    licenseplatedonetool.items = [NSArray arrayWithObjects:
                                  [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(licenseplatedone)],
                                  nil];
    [licenseplatedonetool sizeToFit];
    
    UIToolbar*typeofvehicledoneTool = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    typeofvehicledoneTool.barStyle = UIBarStyleDefault;
    typeofvehicledoneTool.items = [NSArray arrayWithObjects:
                                   [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(typeofvehicledone)],
                                   nil];
    [typeofvehicledoneTool sizeToFit];
    
    self.licenseplatenumbertextfield.inputAccessoryView = licenseplatedonetool;
    self.licenseplatenumbertextfield.delegate=self;
    self.typeofcartextfield.inputAccessoryView = typeofvehicledoneTool;
    self.typeofcartextfield.delegate=self;
    [self.completeBtnReference.titleLabel setTextColor:THEME_COLOR];
}
-(void)licenseplatedone{
    [self.licenseplatenumbertextfield resignFirstResponder];
    [self.typeofcartextfield becomeFirstResponder];
}
-(void)typeofvehicledone{
    [self.typeofcartextfield resignFirstResponder];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
- (void)textFieldDidEndEditing:(UITextField *)textfield{
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

@end
