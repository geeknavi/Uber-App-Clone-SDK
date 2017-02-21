//
//  GeekApplicant.m
//  GeekNavi
//
//  Created by GeekNavi on 11/28/16.
//  Copyright © 2016 GeekNavi. All rights reserved.
//

#import "GeekApplicant.h"

static NSUserDefaults *userDefaults = nil;

@implementation GeekApplicant
@synthesize
currentStep = _currentStep,
zipCode = _zipCode,
fullName = _fullName,
socialSecurityNumber = _socialSecurityNumber,
dateOfBirth = _dateOfBirth,
driverLicenseNumber = _driverLicenseNumber,
profilePicture = _profilePicture,
pictureOfVehicle = _pictureOfVehicle,
pictureOfRegistration = _pictureOfRegistration,
pictureOfInsurance = _pictureOfInsurance,
licensePlateNumber = _licensePlateNumber,
typeOfVehicle = _typeOfVehicle;

-(instancetype)init{
    if (self = [super init]) {
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:groupIDIdentifier];
        if (self.currentStep > 5) {
            self.currentStep = 5;
        }
        
        // General details
        _zipCode = self.zipCode;
        
        // User Specific Details
        _fullName = self.fullName;
        _socialSecurityNumber = self.socialSecurityNumber;
        _dateOfBirth = self.dateOfBirth;
        _driverLicenseNumber = self.driverLicenseNumber;
        
        // Vehicle Specific Details
        _licensePlateNumber = self.licensePlateNumber;
        _typeOfVehicle = self.typeOfVehicle;
        
    }
    return self;
}

/*
    Getters
*/

#pragma mark - Current Step
-(int)currentStep{
    _currentStep = (int)[userDefaults integerForKey:@"application-currentStep"];
    return _currentStep;
}

#pragma mark - General Details
-(NSString *)zipCode{
    _zipCode = [userDefaults objectForKey:@"application-zipCode"];

    return _zipCode;
}

#pragma mark - User Specific Details
-(NSString *)fullName{
    _fullName = [userDefaults objectForKey:@"application-fullName"];

    return _fullName;
}
-(int)socialSecurityNumber{
    _socialSecurityNumber = (int)[userDefaults integerForKey:@"application-socialSecurityNumber"];

    return _socialSecurityNumber;
}
-(NSString *)dateOfBirth{
    _dateOfBirth = [userDefaults objectForKey:@"application-dateOfBirth"];

    return _dateOfBirth;
}
-(NSString *)driverLicenseNumber{
    _driverLicenseNumber = [userDefaults objectForKey:@"application-driverLicenseNumber"];

    return _driverLicenseNumber;
}

#pragma mark - Vehicle Specific Details
-(NSString *)licensePlateNumber{
    _licensePlateNumber = [userDefaults objectForKey:@"application-licensePlateNumber"];
    
    return _licensePlateNumber;
}
-(NSString *)typeOfVehicle{
    _typeOfVehicle = [userDefaults objectForKey:@"application-typeOfVehicle"];
    
    return _typeOfVehicle;
}

/*
 Setters
*/

#pragma mark - Current Step
-(void)setCurrentStep:(int)currentStep{
    _currentStep = currentStep;
    [userDefaults setInteger:currentStep forKey:@"application-currentStep"];
    [userDefaults synchronize];
}

#pragma mark - General Details
-(void)setZipCode:(NSString *)zipCode{
    _zipCode = zipCode;
    
    [userDefaults setObject:zipCode forKey:@"application-zipCode"];
    [userDefaults synchronize];
}

#pragma mark - User Specific Details
-(void)setFullName:(NSString *)fullName{
    _fullName = fullName;
    [userDefaults setObject:fullName forKey:@"application-fullName"];
    [userDefaults synchronize];
}
-(void)setSocialSecurityNumber:(int)socialSecurityNumber{
    _socialSecurityNumber = socialSecurityNumber;
    [userDefaults setObject:@(socialSecurityNumber) forKey:@"application-socialSecurityNumber"];
    [userDefaults synchronize];
}
-(void)setDateOfBirth:(NSString *)dateOfBirth{
    _dateOfBirth = dateOfBirth;
    [userDefaults setObject:dateOfBirth forKey:@"application-dateOfBirth"];
    [userDefaults synchronize];
}
-(void)setDriverLicenseNumber:(NSString *)driverLicenseNumber{
    _driverLicenseNumber = driverLicenseNumber;
    [userDefaults setObject:driverLicenseNumber forKey:@"application-driverLicenseNumber"];
    [userDefaults synchronize];
}
-(void)setProfilePicture:(UIImage *)profilePicture{
    _profilePicture = profilePicture;
    
    // Save the profile picture
    [GeekNavi editUserInformationWithParameters:@{@"vFirst":userInformation[@"vFirst"],
                                                  @"vLast":userInformation[@"vLast"]}
                                          image:profilePicture block:^(id JSON, WebServiceResult geekResult) {
                                              //
                                          }];
}

-(void)setLicensePlateNumber:(NSString *)licensePlateNumber{
    _licensePlateNumber = licensePlateNumber;
    [userDefaults setObject:licensePlateNumber forKey:@"application-licensePlateNumber"];
    [userDefaults synchronize];
}

-(void)setTypeOfVehicle:(NSString *)typeOfVehicle{
    _typeOfVehicle = typeOfVehicle;
    [userDefaults setObject:typeOfVehicle forKey:@"application-typeOfVehicle"];
    [userDefaults synchronize];
}

-(void)applyWithResultBlock:(GeekNaviWebResultsBlock)resultBlock{
    // If nil, initalize with empty string
    if (self.referralCode == nil) {
        self.referralCode = @"";
    }
    
    
    // General Details
    if (_zipCode == nil){
        NSLog(@"GeekNavi: Zip code is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }else if (self.selectedCity == nil){
        NSLog(@"GeekNavi: Selected city is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }else if (self.referralCode == nil){
        NSLog(@"GeekNavi: Referral is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }
    
    // User Specific Details
    else if (_fullName == nil) {
        NSLog(@"GeekNavi: Fullname is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }else if (_dateOfBirth == nil){
        NSLog(@"GeekNavi: Date of birth is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }else if (_driverLicenseNumber == nil){
        NSLog(@"GeekNavi: Driver license number is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }else if (_profilePicture == nil){
        NSLog(@"GeekNavi: Profile picture is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }
    
    // Vehicle Specific Details
    else if (_pictureOfVehicle == nil){
        NSLog(@"GeekNavi: Picture of vehicle is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }else if (_pictureOfRegistration == nil){
        NSLog(@"GeekNavi: Picture of registration is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }else if (_pictureOfInsurance == nil){
        NSLog(@"GeekNavi: Picture of insurance is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }else if (_licensePlateNumber == nil){
        NSLog(@"GeekNavi: License plate number is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }else if (_typeOfVehicle == nil){
        NSLog(@"GeekNavi: Type of vehicle is nil. Quitting application stage!");
        resultBlock(nil,WebServiceResultError);
        return;
    }
    
    // IF all OK, continue
    [self beginUploadingImage:CARPICTURE image:_pictureOfVehicle block:^(id JSON, WebServiceResult geekResult) {
        if (geekResult == WebServiceResultSuccess) {
            [self beginUploadingImage:INSURANCEPICTURE image:_pictureOfInsurance block:^(id JSON, WebServiceResult geekResult) {
                if (geekResult == WebServiceResultSuccess) {
                    [self beginUploadingImage:REGPICTURE image:_pictureOfRegistration block:^(id JSON, WebServiceResult geekResult) {
                        if (geekResult == WebServiceResultSuccess) {
                            [GeekNavi finalizeApplication:@{
                                                            @"fullname":_fullName,
                                                            @"SSN":@(_socialSecurityNumber),
                                                            @"DOB":_dateOfBirth,
                                                            @"licensenumber":_licensePlateNumber,
                                                            @"zipcode":_zipCode,
                                                            @"refferal":self.referralCode,
                                                            @"city":self.selectedCity,
                                                            @"status":@"pending",
                                                            @"typeofcar":_typeOfVehicle,
                                                            @"platenumber":_licensePlateNumber
                                                            } block:^(id JSON, WebServiceResult geekResult) {
                                                                resultBlock(JSON,geekResult);
                                                            }];
                        }else{
                            resultBlock(JSON,geekResult);
                        }
                    }];
                }else{
                    resultBlock(JSON,geekResult);
                }
            }];
        }else{
            resultBlock(JSON,geekResult);
        }
    }];
}

#pragma mark - Reset
-(void)resetApplication{
    // Current Step
    [userDefaults removeObjectForKey:@"application-currentStep"];
    
    // General Details
    [userDefaults removeObjectForKey:@"application-zipCode"];
    
    // User Specific Details
    [userDefaults removeObjectForKey:@"application-fullName"];
    [userDefaults removeObjectForKey:@"application-socialSecurityNumber"];
    [userDefaults removeObjectForKey:@"application-dateOfBirth"];
    [userDefaults removeObjectForKey:@"application-driverLicenseNumber"];
    
    // Vehicle Specific Details
    [userDefaults removeObjectForKey:@"application-licensePlateNumber"];
    [userDefaults removeObjectForKey:@"application-typeOfVehicle"];
}

#pragma mark - Begin Uploading
-(void)beginUploadingImage:(NSString *)type image:(UIImage *)image block:(GeekNaviWebResultsBlock)callback{
    [GeekNavi uploadImage:type image:image block:callback];
}

#pragma mark - Documents Path
- (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}


@end
