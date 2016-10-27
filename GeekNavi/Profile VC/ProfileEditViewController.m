#import "ProfileEditViewController.h"
#import "Constant.h"
#import <GeekNavi/GeekPhotoLibrary.h>

@interface ProfileEditViewController ()<GeekPhotoLibraryDelegate>{
    __weak IBOutlet UITextField *txtFirstName;
    __weak IBOutlet UITextField *txtLastName;
    __weak IBOutlet UITextField *phonenumber;
    __weak IBOutlet UILabel *currentearnings;
    
    __weak IBOutlet UIButton *_btnProfile;
    __weak IBOutlet UITextField *paypalemailtextfield;
    __weak IBOutlet UIImageView *profilePictureImageView;
    
    __weak IBOutlet UILabel *setuppaypalpayouttext;
    __weak IBOutlet UIView *topview;
    __weak IBOutlet UIButton *savePaypalBtnRef;
    
    __weak IBOutlet UIButton *payoutSettingsButton;
    __weak IBOutlet UIImageView        *driverImg;
    __weak IBOutlet UIButton *bringupPaypalViewRef;
    
    __weak IBOutlet UIView *menuView;
    
    __weak IBOutlet UIView *paypalview;
    
    __weak IBOutlet UILabel *referralcode;
}
@end

@implementation ProfileEditViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(submitPaypalEmail)],
                           nil];
    [numberToolbar sizeToFit];
    paypalemailtextfield.inputAccessoryView = numberToolbar;
    
    [GeekPhotoLibrary sharedInstance].delegate=self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Settings";
    
    [self themeOptimization];
    [self stateConfiguration];
    [self performSelector:@selector(fetchPreviousDetails) withObject:nil afterDelay:0.01f];
}

#pragma mark - Submits the drivers Paypal Email
-(void)submitPaypalEmail{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        if ([emailTest evaluateWithObject:paypalemailtextfield.text] == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid E-mail Address!" message:@"Please Enter Valid Email Address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }else{
            addLoading(NSLocalizedString(@"updating_paypal", nil));
            [GeekNavi updatePaypalDriverEmail:paypalemailtextfield.text block:^(id JSON, WebServiceResult geekResult) {
                if (geekResult==WebServiceResultSuccess) {
                    removeLoading();
                    [paypalemailtextfield resignFirstResponder];
                    [self closePayoutSettings:self];
                    showAlertViewWithMessage(NSLocalizedString(@"thank_you_payout_details", nil));
                    paypalemailtextfield.text=@"";
                    setuppaypalpayouttext.text=@"UPDATE PAYPAL PAYOUT";
                }else{
                    showAlertViewWithMessage(NSLocalizedString(@"general_error", nil));
                }
            }];
            
        }
}

#pragma mark -Photo Delegate Method
-(void)geekPhotoLibraryReturnDelegate:(UIImage *)selectedPhoto{
    CGRect rect = CGRectMake(0,0,150,150);
    UIGraphicsBeginImageContext( rect.size );
    [selectedPhoto drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img=[UIImage imageWithData:imageData];
    [profilePictureImageView setImage:img];
    
    // Setting the image is optional, if you don't want to change the image passing nil is fine
    [GeekNavi editUserInformationWithParameters:@{@"vFirst":userInformation[@"vFirst"],@"vLast":userInformation[@"vLast"]} image:profilePictureImageView.image block:^(id JSON, WebServiceResult geekResult) {
        if(geekResult==WebServiceResultSuccess){
            NSLog(@"Success!");
        }
    }];
}

#pragma mark -Support Method
-(BOOL)checkUserInput{
    if(![NSStringWithoutSpace(txtFirstName.text) length])
    {
        showAlertViewWithMessage(NSLocalizedString(@"first_name_blank", nil));
        return NO;
    }
    else if(![NSStringWithoutSpace(txtLastName.text) length])
    {
        showAlertViewWithMessage(NSLocalizedString(@"last_name_blank", nil));
        return NO;
    }else if(![NSStringWithoutSpace(phonenumber.text) length])
    {
        showAlertViewWithMessage(NSLocalizedString(@"phone_number_blank", nil));
        return NO;
    }
    return YES;
}
#pragma mark - IBActions
- (IBAction)paypalViewBtn:(id)sender {
    [paypalview setHidden:NO];
    bringupPaypalViewRef.enabled=NO;
    [self.view bringSubviewToFront:paypalview];
}
- (IBAction)savePaypalinfo:(id)sender {
    [self closePayoutSettings:self];
}

- (IBAction)payoutSettingsBtn:(id)sender {
    [GeekNavi getDriverCurrentEarnings:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            double formatingearnings = [JSON[@"data"] doubleValue];
            NSString *earnings = [NSString stringWithFormat:@"%.02f %@", formatingearnings,currency];
            currentearnings.text=earnings;
        }else{
            currentearnings.text=[NSString stringWithFormat:@"0 %@",currency];
        }
    }];
    
    [menuView setHidden:NO];
    
    [self.view bringSubviewToFront:menuView];
}
- (IBAction)closePayoutSettings:(id)sender {
    [menuView setHidden:YES];
    [paypalview setHidden:YES];
    bringupPaypalViewRef.enabled=YES;
}
- (IBAction)sendImageAction:(id)sender{
    [self.view endEditing:YES];
    [[GeekPhotoLibrary sharedInstance]openPhotoFromCameraAndLibrary:self];
}
#pragma mark - Screen Customizations
-(void)fetchPreviousDetails{
    txtFirstName.text=userInformation[@"vFirst"];
    txtLastName.text=userInformation[@"vLast"];
    phonenumber.text=userInformation[@"userPhone"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userInformation[@"profileImage"][@"original"]]];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        [profilePictureImageView setImage:image];
    }
    profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.height/2;
}
-(void)themeOptimization{
    [self.view setBackgroundColor:THEME_COLOR];
    [payoutSettingsButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [menuView setBackgroundColor:THEME_COLOR];
    [paypalview setBackgroundColor:THEME_COLOR];
}
-(void)stateConfiguration{
    if ([userInformation[@"vDriverorNot"]isEqualToString:@"driver"]) {
        [payoutSettingsButton setEnabled:YES];
        [payoutSettingsButton setHidden:NO];
        [referralcode setHidden:NO];
        referralcode.text = [NSString stringWithFormat:@"Refferal code: %@%@",userInformation[@"vFirst"],userInformation[@"iUserID"]];
    }else if([userInformation[@"vDriverorNot"]isEqualToString:@"pending"]){
        [payoutSettingsButton setEnabled:YES];
        [payoutSettingsButton setHidden:NO];
    }else if([userInformation[@"vDriverorNot"]isEqualToString:@"carpicture"]){
        [payoutSettingsButton setEnabled:YES];
        [payoutSettingsButton setHidden:NO];
    }else if([userInformation[@"vDriverorNot"]isEqualToString:@"registration"]){
        [payoutSettingsButton setEnabled:YES];
        [payoutSettingsButton setHidden:NO];
    }else if([userInformation[@"vDriverorNot"]isEqualToString:@"picture"]){
        [payoutSettingsButton setEnabled:YES];
        [payoutSettingsButton setHidden:NO];
    }else if([userInformation[@"vDriverorNot"]isEqualToString:@"progress"]){
        [payoutSettingsButton setEnabled:YES];
        [payoutSettingsButton setHidden:NO];
    }else if([userInformation[@"vDriverorNot"]isEqualToString:@"insurance"]){
        [payoutSettingsButton setEnabled:YES];
        [payoutSettingsButton setHidden:NO];
    }
}

@end
