#import <Availability.h>
#undef weak_delegate
#if __has_feature(objc_arc_weak)
#define weak_delegate weak
#else
#define weak_delegate unsafe_unretained
#endif


#import <UIKit/UIKit.h>


@class GeekNaviCountryPicker;

@protocol GeekNaviCountryPickerDelegate <UIPickerViewDelegate>

- (void)GeekNaviCountryPicker:(GeekNaviCountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code;

@end

@interface GeekNaviCountryPicker : UIPickerView

+ (NSArray *)countryNames;
+ (NSArray *)countryCodes;
+ (NSDictionary *)countryNamesByCode;
+ (NSDictionary *)countryCodesByName;

@property (nonatomic, weak_delegate) id<GeekNaviCountryPickerDelegate> delegate;

@property (nonatomic, copy) NSString *selectedCountryName;
@property (nonatomic, copy) NSString *selectedCountryCode;
@property (nonatomic, copy) NSLocale *selectedLocale;

@property (nonatomic, strong) UIFont *labelFont;

- (void)setSelectedCountryCode:(NSString *)countryCode animated:(BOOL)animated;
- (void)setSelectedCountryName:(NSString *)countryName animated:(BOOL)animated;
- (void)setSelectedLocale:(NSLocale *)locale animated:(BOOL)animated;

+(NSString *)getCountryCode:(NSString *)input;

+(void)changeFlagDependingOnCode:(NSString *)numberCode returnImage:(void (^)(UIImage *image))returnBlock;

@end
