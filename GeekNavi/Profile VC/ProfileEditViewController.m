#import "ProfileEditViewController.h"
#import "Constant.h"
#import <GeekNavi/GeekPhotoLibrary.h>

@interface ProfileEditViewController ()<GeekPhotoLibraryDelegate,UIActionSheetDelegate>{
    // Text Fields
    __weak IBOutlet UITextField *txtFirstName;
    __weak IBOutlet UITextField *txtLastName;
    __weak IBOutlet UITextField *phonenumber;
    
    // Labels
    __weak IBOutlet UILabel *referralcode;
    __weak IBOutlet UILabel *editLabel;
    
    // Buttons
    __weak IBOutlet UIButton *_btnProfile;
    __weak IBOutlet UIButton *payoutSettingsButton;
    
    // Image Views
    __weak IBOutlet UIImageView *profilePictureImageView;
}
@end

@implementation ProfileEditViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    // As always, start with customizing the screen (MAIN/SUB Colors)
    [self customizeScreen];
    [self fetchPreviousDetails];
    [self stateConfiguration];
    
    [GeekPhotoLibrary sharedInstance].delegate=self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Profile";
}

#pragma mark - Payout Settings Action
- (IBAction)payoutSettingsBtn:(id)sender {
    [self performSegueWithIdentifier:@"payoutSettingsSegue" sender:nil];
}

#pragma mark - Edit Profile Picture Action
- (IBAction)editImageAction:(id)sender {
    UIActionSheet *sheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"take_new_picture", nil),NSLocalizedString(@"use_existing_picture", nil), nil];
    [sheet showInView:self.view];
}

#pragma mark -Photo Delegate Method
-(void)geekPhotoLibraryReturnDelegate:(UIImage *)selectedPhoto{
    CGRect rect = CGRectMake(0,0,150,150);
    UIGraphicsBeginImageContext( rect.size );
    [selectedPhoto drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img = [UIImage imageWithData:imageData];
    [profilePictureImageView setImage:img];
    
    // Passing an image is optional, if you don't want to change the image passing nil is fine
    [GeekNavi editUserInformationWithParameters:@{@"vFirst":userInformation[@"vFirst"],@"vLast":userInformation[@"vLast"]} image:profilePictureImageView.image block:^(id JSON, WebServiceResult geekResult) {
        if(geekResult==WebServiceResultSuccess){
            NSLog(@"Success!");
        }
    }];
}

#pragma mark - Fetch Previous Details
-(void)fetchPreviousDetails{
    txtFirstName.text = userInformation[@"vFirst"];
    txtLastName.text = userInformation[@"vLast"];
    phonenumber.text = userInformation[@"userPhone"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userInformation[@"profileImage"][@"original"]]];
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        [profilePictureImageView setImage:image];
    }
    profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.height/2;
}

#pragma mark - Customize Screen
-(void)customizeScreen{
    [self.view setBackgroundColor:MAIN_THEME_COLOR];

    [payoutSettingsButton setBackgroundColor:SUB_THEME_COLOR];
    
    [txtFirstName setTextColor:SUB_THEME_COLOR];
    [txtLastName setTextColor:SUB_THEME_COLOR];
    [editLabel setTextColor:SUB_THEME_COLOR];
    [referralcode setTextColor:SUB_THEME_COLOR];
    [phonenumber setTextColor:SUB_THEME_COLOR];

    payoutSettingsButton.layer.cornerRadius = 10.0f;
    payoutSettingsButton.layer.masksToBounds = YES;
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"take_new_picture", nil)]){
        [[GeekPhotoLibrary sharedInstance] takeNewPictureFromViewController:self];
    }else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"use_existing_picture", nil)]){
        [[GeekPhotoLibrary sharedInstance] useExistingPictureFromViewController:self];
    }
}

#pragma mark - State Configuration
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
