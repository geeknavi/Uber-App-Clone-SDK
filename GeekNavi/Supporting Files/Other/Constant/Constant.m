#import "Constant.h"
#import "MBProgressHUD.h"

BOOL validateEmail(NSString *checkString){
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

void showAlertViewWithMessage(NSString* msg){
    removeLoading();
    
    UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Error"
                                    message:msg
                                    preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    [topController presentViewController:alert animated:YES completion:nil];
}

void downloadImageFromUrl(NSString* urlString, UIImageView * imageview){
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        UIImage *img = [UIImage imageWithData:data];
        if(img) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageview.image=img;
            });
        }
    });
}

void addLoading(NSString *loadingText){
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    if (loadingText.length != 0) {
        hud.labelText = loadingText;
    }
}

void removeLoading(){
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

NSString* NSStringWithoutSpace(NSString* string)
{
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}
