#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GeekNavi.h"

#define IS_IPHONE4 (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)

extern BOOL validateEmail(NSString* checkString);

extern void showAlertViewWithMessage(NSString* msg);

extern void downloadImageFromUrl(NSString* urlString, UIImageView * imageview);

extern void addLoading(NSString *loadingText);
extern void removeLoading();

extern NSString* NSStringWithoutSpace(NSString* string);