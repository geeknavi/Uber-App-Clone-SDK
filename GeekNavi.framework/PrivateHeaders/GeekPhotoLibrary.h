#import <UIKit/UIKit.h>

@protocol GeekPhotoLibraryDelegate;

@protocol GeekPhotoLibraryDelegate <NSObject>
-(void)geekPhotoLibraryReturnDelegate:(UIImage *)selectedPhoto;
@end

@interface GeekPhotoLibrary : NSObject <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSString *cameraString;
    NSString *libraryString;
}

+(GeekPhotoLibrary *)sharedInstance;

@property(nonatomic,weak)id <GeekPhotoLibraryDelegate> delegate;

-(void)takeNewPictureFromViewController:(UIViewController *)controller;
-(void)useExistingPictureFromViewController:(UIViewController *)controller;

@end


