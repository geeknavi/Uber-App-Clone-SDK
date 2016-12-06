//
//  GeekApplicant.h
//  GeekNavi
//
//  Created by GeekNavi on 11/28/16.
//  Copyright © 2016 GeekNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GeekNavi/GeekNavi.h>

@interface GeekApplicant : NSObject
NS_ASSUME_NONNULL_BEGIN

// General Details
@property (nonatomic, strong) NSString *referralCode;
@property (nonatomic, strong) NSString *selectedCity;
@property (nonatomic, strong) NSString *zipCode;

// User Specific Details
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic) int socialSecurityNumber;
@property (nonatomic, strong) NSString *dateOfBirth;
@property (nonatomic, strong) NSString *driverLicenseNumber;
@property (nonatomic, strong) UIImage *profilePicture;

// Vehicle Specific Details
@property (nonatomic, strong) UIImage *pictureOfVehicle;
@property (nonatomic, strong) UIImage *pictureOfRegistration;
@property (nonatomic, strong) UIImage *pictureOfInsurance;

@property (nonatomic, strong) NSString *licensePlateNumber;
@property (nonatomic, strong) NSString *typeOfVehicle;

// Setting Properties
@property (nonatomic) int currentStep;

// Methods
-(void)applyWithResultBlock:(GeekNaviWebResultsBlock)resultBlock;
-(void)resetApplication;
-(instancetype)init;

NS_ASSUME_NONNULL_END

@end
