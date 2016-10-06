//
//  SEMoreInfoApplication.m
//  GeekNavi
//
//  Created by GeekNavi on 7/13/15.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import "SEMoreInfoApplication.h"
#import <GeekNavi/GeekPhotoLibrary.h>


@interface SEMoreInfoApplication () <GeekPhotoLibraryDelegate>{
    __weak IBOutlet UIButton *uploadNowBtn;
    __weak IBOutlet UIButton *maybeLaterBtn;
    __weak IBOutlet UIImageView *imgVProfile;
    __weak IBOutlet UILabel *infoLabel;
    BOOL        localpicture;
    NSString *returnString;
}

@end

@implementation SEMoreInfoApplication
@synthesize needInfoString;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInformation];
    [self customizeScreen];
    
    [GeekPhotoLibrary sharedInstance].delegate=self;
}
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
        [self sendtoDatabase:INSURANCEPICTURE];
    }else if([needInfoString isEqualToString:@"registration"]){
        [self sendtoDatabase:REGISTRATIONPIC];
    }else if([needInfoString isEqualToString:@"carpicture"]){
        [self sendtoDatabase:CARPICTURE];
    }else if([needInfoString isEqualToString:@"picture"]){
        [self changeProfileImage];
    }
    
}

- (IBAction)uploadNow:(id)sender {
    [[GeekPhotoLibrary sharedInstance]openPhotoFromCameraAndLibrary:self];
}
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
                        showAlertViewWithMessage(JSON[@"message"]);
                    }else{
                        removeLoading();
                    }
                }
            }];
        }
    }];
}
-(void)sendtoDatabase:(NSString *)type{
    [GeekNavi uploadImage:type image:imgVProfile.image block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            [GeekNavi changeToPendingApplication:^(id JSON, WebServiceResult geekResult) {
                if (geekResult==WebServiceResultSuccess) {
                    removeLoading();
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    imgVProfile.image = [UIImage imageNamed:@"car-png.png"];
                    if (JSON[@"message"]) {
                        showAlertViewWithMessage(JSON[@"message"]);
                    }else{
                        removeLoading();
                    }
                }
            }];
        }else if (geekResult==WebServiceResultFail){
            imgVProfile.image = [UIImage imageNamed:@"car-png.png"];
            if (JSON[@"message"]) {
                showAlertViewWithMessage(JSON[@"message"]);
            }else{
                removeLoading();
            }
        }
    }];
}
- (IBAction)maybeLater:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)customizeScreen{
    [self.view setBackgroundColor:THEME_COLOR];
    [uploadNowBtn setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    
    maybeLaterBtn.layer.cornerRadius = 5;
    maybeLaterBtn.layer.masksToBounds = YES;
    uploadNowBtn.layer.cornerRadius = 5;
    uploadNowBtn.layer.masksToBounds = YES;
    imgVProfile.frame = CGRectMake((self.view.frame.size.width/2) - (imgVProfile.frame.size.width/2),imgVProfile.frame.origin.y,
                                   imgVProfile.frame.size.width,
                                   imgVProfile.frame.size.height);
}


@end
