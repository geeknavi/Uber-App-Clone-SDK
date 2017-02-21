//
//  SEMoreInfoApplication.m
//  GeekNavi
//
//  Created by GeekNavi on 7/13/15.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "SEMoreInfoApplication.h"
#import <GeekNavi/GeekPhotoLibrary.h>

@interface SEMoreInfoApplication () <GeekPhotoLibraryDelegate,UIActionSheetDelegate>{
    // Buttons
    __weak IBOutlet UIButton *uploadNowBtn;
    __weak IBOutlet UIButton *maybeLaterBtn;
    
    // UIImageViews
    __weak IBOutlet UIImageView *imgVProfile;
    
    // UILabels
    __weak IBOutlet UILabel *infoLabel;
    __weak IBOutlet UILabel *neededInformationLabel;
    __weak IBOutlet UILabel *moreInfoLabel;
}

@end

@implementation SEMoreInfoApplication
@synthesize needInfoString;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // As always, start with customizing the screen (MAIN/SUB Colors)
    [self customizeScreen];
    
    // Load information
    [self loadInformation];
    
    [GeekPhotoLibrary sharedInstance].delegate=self;
}

#pragma mark - Upload   Now Action
- (IBAction)uploadNow:(id)sender {
    UIActionSheet *sheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"take_new_picture", nil),NSLocalizedString(@"use_existing_picture", nil), nil];
    [sheet showInView:self.view];
}

#pragma mark - Maybe Later Action
- (IBAction)maybeLater:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Change Profile Image
-(void)changeProfileImage{
    [GeekNavi editUserInformationWithParameters:@{@"vFirst":userInformation[@"vFirst"],@"vLast":userInformation[@"vLast"]} image:imgVProfile.image block:^(id JSON, WebServiceResult geekResult) {
        if(geekResult==WebServiceResultSuccess){
            [GeekNavi changeToPendingApplication:^(id JSON, WebServiceResult geekResult) {
                if (geekResult==WebServiceResultSuccess) {
                    removeLoading();
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    imgVProfile.image = [UIImage imageNamed:@"car-png.png"];
                    if (JSON[@"message"]) {
                        showAlertViewWithTitleAndMessage(nil,JSON[@"message"]);
                    }else{
                        removeLoading();
                    }
                }
            }];
        }
    }];
}

#pragma mark - Upload image to Database
-(void)uploadImageToDatabase:(NSString *)type{
    [GeekNavi uploadImage:type image:imgVProfile.image block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            [GeekNavi changeToPendingApplication:^(id JSON, WebServiceResult geekResult) {
                if (geekResult==WebServiceResultSuccess) {
                    removeLoading();
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    imgVProfile.image = [UIImage imageNamed:@"car-png.png"];
                    if (JSON[@"message"]) {
                        showAlertViewWithTitleAndMessage(nil,JSON[@"message"]);
                    }else{
                        removeLoading();
                    }
                }
            }];
        }else if (geekResult==WebServiceResultFail){
            imgVProfile.image = [UIImage imageNamed:@"car-png.png"];
            if (JSON[@"message"]) {
                showAlertViewWithTitleAndMessage(nil,JSON[@"message"]);
            }else{
                removeLoading();
            }
        }
    }];
}

#pragma mark - Customize Screen
-(void)customizeScreen{
    [self.view setBackgroundColor:MAIN_THEME_COLOR];
    [uploadNowBtn setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
    [moreInfoLabel setTextColor:SUB_THEME_COLOR];
    [infoLabel setTextColor:SUB_THEME_COLOR];
    [neededInformationLabel setTextColor:SUB_THEME_COLOR];
    
    maybeLaterBtn.layer.cornerRadius = 10.0f;
    maybeLaterBtn.layer.masksToBounds = YES;
    
    uploadNowBtn.layer.cornerRadius = 10.0f;
    uploadNowBtn.layer.masksToBounds = YES;
    
    imgVProfile.frame = CGRectMake((self.view.frame.size.width/2) - (imgVProfile.frame.size.width/2),imgVProfile.frame.origin.y,imgVProfile.frame.size.width, imgVProfile.frame.size.height);
}

#pragma mark - Load Information
-(void)loadInformation{
    if ([needInfoString isEqualToString:@"insurance"]) {
        infoLabel.text = @"Proof of insurance";
    }else if([needInfoString isEqualToString:@"registration"]){
        infoLabel.text = @"Proof of registration";
    }else if([needInfoString isEqualToString:@"carpicture"]){
        infoLabel.text = @"Picture of your vehicle";
    }else if([needInfoString isEqualToString:@"picture"]){
        infoLabel.text = @"Picture of yourself";
    }
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"take_new_picture", nil)]){
        [[GeekPhotoLibrary sharedInstance] takeNewPictureFromViewController:self];
    }else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"use_existing_picture", nil)]){
        [[GeekPhotoLibrary sharedInstance] useExistingPictureFromViewController:self];
    }
}

#pragma mark -Photo Delegate Method
-(void)geekPhotoLibraryReturnDelegate:(UIImage *)selectedPhoto{
    addLoading(NSLocalizedString(@"processing_picture", nil));
    
    CGRect rect = CGRectMake(0,0,800,800);
    UIGraphicsBeginImageContext( rect.size );
    [selectedPhoto drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img=[UIImage imageWithData:imageData];
    [imgVProfile setImage:img];
    
    if ([needInfoString isEqualToString:@"insurance"]) {
        [self uploadImageToDatabase:INSURANCEPICTURE];
    }else if([needInfoString isEqualToString:@"registration"]){
        [self uploadImageToDatabase:REGPICTURE];
    }else if([needInfoString isEqualToString:@"carpicture"]){
        [self uploadImageToDatabase:CARPICTURE];
    }else if([needInfoString isEqualToString:@"picture"]){
        [self changeProfileImage];
    }
}


@end
