//
//  SESecondApplicationPage.m
//  GeekNavi
//
//  Created by GeekNavi on 6/6/15.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "SESecondApplicationPage.h"
#import "SEVehicleinformation.h"
#import <GeekNavi/GeekPhotoLibrary.h>

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
#define MONTH_MAXLENGTH 2
#define DAY_MAXLENGTH 2
#define YEAR_MAXLENGTH 4

@interface SESecondApplicationPage () <GeekPhotoLibraryDelegate,UITextFieldDelegate>{
    BOOL localpicture;
    BOOL picturetaken;
    BOOL showOnce;
    CGFloat animatedDistance;
    
    __weak IBOutlet UIImageView *imgVProfile;
}
@property (weak, nonatomic) IBOutlet UIView *SSNmoveup;
@property (weak, nonatomic) IBOutlet UITextField *legalfullname;
@property (weak, nonatomic) IBOutlet UILabel *pictureofyourselflabel;
@property (weak, nonatomic) IBOutlet UITextField *SSN;
@property (weak, nonatomic) IBOutlet UITextField *day;
@property (weak, nonatomic) IBOutlet UITextField *month;
@property (weak, nonatomic) IBOutlet UITextField *year;
@property (weak, nonatomic) IBOutlet UITextField *licensenumber;
@property (weak, nonatomic) IBOutlet UIView *nameview;
@property (weak, nonatomic) IBOutlet UIView *DOBview;
@property (weak, nonatomic) IBOutlet UIView *licenseview;
@property (weak, nonatomic) IBOutlet UIButton *nextbuttonRef;
@property (weak, nonatomic) IBOutlet UIButton *beginAppRef;
@property (weak, nonatomic) IBOutlet UIButton *changeImgRef;
@property (weak, nonatomic) IBOutlet UIView *informationview;
@property (weak, nonatomic) IBOutlet UIImageView *pictureofyourself;

@end

@implementation SESecondApplicationPage
@synthesize selectedCity,referralCode,zipCode;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeToolBarsAndSetActions];
    
    [self.nextbuttonRef.titleLabel setTextColor:THEME_COLOR];
    [GeekPhotoLibrary sharedInstance].delegate=self;
    
    if ([userInformation[@"profileImage"][@"original"] isEqualToString:@""]) {
        localpicture = NO;
    }else{
        downloadImageFromUrl(userInformation[@"profileImage"][@"original"], self.pictureofyourself);
        imgVProfile.layer.cornerRadius = imgVProfile.frame.size.height/2;
        localpicture = YES;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
#pragma mark - Photo Delegate
-(void)geekPhotoLibraryReturnDelegate:(UIImage *)selectedPhoto{
    addLoading(@"");
    
    CGRect rect = CGRectMake(0,0,150,150);
    UIGraphicsBeginImageContext( rect.size );
    [selectedPhoto drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img=[UIImage imageWithData:imageData];
    [imgVProfile setImage:img];
    picturetaken = YES;
    
    [GeekNavi editUserInformationWithParameters:@{@"vFirst":userInformation[@"vFirst"],@"vLast":userInformation[@"vLast"]} image:imgVProfile.image block:^(id JSON, WebServiceResult geekResult) {
        removeLoading();
    }];
}

#pragma mark - IBActions
- (IBAction)beginapplication:(id)sender {
    if (localpicture == NO && picturetaken == NO) {
        showAlertViewWithMessage(NSLocalizedString(@"application_profile_picture_blank", nil));
    }else{
        [self.legalfullname becomeFirstResponder];
    }
}
- (IBAction)changeimage:(id)sender {
    [[GeekPhotoLibrary sharedInstance]openPhotoFromCameraAndLibrary:self];
}
- (IBAction)cancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextButtonAction:(id)sender {
    if (picturetaken) {
        [self postPictureWithBlock:^(BOOL complete) {
            if (complete) {
                [self performSegueWithIdentifier:@"vehicleInfoSegue" sender:nil];
            }
        }];
    }else{
        [self performSegueWithIdentifier:@"vehicleInfoSegue" sender:nil];
    }
    
}
-(void)postPictureWithBlock:(void(^)(BOOL complete))callback{
    [GeekNavi editUserInformationWithParameters:@{@"applicationImage":@"YES"} image:imgVProfile.image block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            callback(YES);
        }else{
            if (JSON[@"message"]) {
                showAlertViewWithMessage(JSON[@"message"]);
            }
            callback(NO);
        }
    }];
}
#pragma mark - Tool Bar Actions & Customizations
-(void)customizeToolBarsAndSetActions{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(legalfullnamenext)],
                           nil];
    [numberToolbar sizeToFit];
    
    UIToolbar*SSNNextTool = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    SSNNextTool.barStyle = UIBarStyleDefault;
    SSNNextTool.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(SSNnext)],
                         nil];
    [SSNNextTool sizeToFit];
    
    UIToolbar*daynexttool = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    daynexttool.barStyle = UIBarStyleDefault;
    daynexttool.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(daynext)],
                         nil];
    [daynexttool sizeToFit];
    
    UIToolbar*monthnexttool = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    monthnexttool.barStyle = UIBarStyleDefault;
    monthnexttool.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(monthnext)],
                           nil];
    [monthnexttool sizeToFit];
    
    UIToolbar*yearnexttool = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    yearnexttool.barStyle = UIBarStyleDefault;
    yearnexttool.items = [NSArray arrayWithObjects:
                          [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(yearnext)],
                          nil];
    [yearnexttool sizeToFit];
    
    UIToolbar*completetexttool = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    completetexttool.barStyle = UIBarStyleDefault;
    completetexttool.items = [NSArray arrayWithObjects:
                              [[UIBarButtonItem alloc]initWithTitle:@"Vehicle Information" style:UIBarButtonItemStyleDone target:self action:@selector(completetextfield)],
                              nil];
    [completetexttool sizeToFit];
    
    self.legalfullname.inputAccessoryView = numberToolbar;
    self.SSN.inputAccessoryView = SSNNextTool;
    self.day.inputAccessoryView = daynexttool;
    self.month.inputAccessoryView = monthnexttool;
    self.year.inputAccessoryView = yearnexttool;
    self.licensenumber.inputAccessoryView = completetexttool;
    
    self.legalfullname.delegate=self;
    self.SSN.delegate=self;
    self.day.delegate=self;
    self.month.delegate=self;
    self.year.delegate=self;
    self.licensenumber.delegate=self;
}
-(void)legalfullnamenext{
    self.beginAppRef.enabled=NO;
    if ([self.legalfullname.text isEqualToString:@""]) {
        showAlertViewWithMessage(NSLocalizedString(@"application_full_name_blank", nil));
    }
    [self.SSN becomeFirstResponder];
}
-(void)SSNnext{
    [self.day becomeFirstResponder];
}
-(void)daynext{
    if ([self.day.text isEqualToString:@""]) {
        showAlertViewWithMessage(NSLocalizedString(@"application_dob_blank", nil));
    }
    [self.month becomeFirstResponder];
}
-(void)monthnext{
    if ([self.month.text isEqualToString:@""]) {
        showAlertViewWithMessage(NSLocalizedString(@"application_dob_blank", nil));
    }
    [self.year becomeFirstResponder];

}
-(void)yearnext{
    if ([self.year.text isEqualToString:@""]) {
        showAlertViewWithMessage(NSLocalizedString(@"application_dob_blank", nil));
    }
    [self.licensenumber becomeFirstResponder];
}
-(void)completetextfield{
    if (self.licensenumber.text.length == 0) {
        showAlertViewWithMessage(NSLocalizedString(@"application_required_field", nil));
    }
    [self.nextbuttonRef setEnabled:YES];
    [self.view endEditing:YES];
}

#pragma mark - Keyboard Animations
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.day) {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= DAY_MAXLENGTH || returnKey;
    }else if (textField == self.month) {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= MONTH_MAXLENGTH || returnKey;
    }else if (textField == self.year) {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        return newLength <= YEAR_MAXLENGTH || returnKey;
    }
    return YES;
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

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"vehicleInfoSegue"]) {
        SEVehicleinformation *vc = (SEVehicleinformation *)[segue destinationViewController];
        vc.selectedCity = selectedCity;
        vc.referralCode = referralCode;
        vc.zipCode = zipCode;
        vc.dateOfBirth = [NSString stringWithFormat:@"%@%@%@",self.month.text, self.day.text, self.year.text];
        vc.fullName = self.legalfullname.text;
        vc.socialSecurityNumber = self.SSN.text;
        vc.licenseNumber = self.licensenumber.text;
    }
}
@end
