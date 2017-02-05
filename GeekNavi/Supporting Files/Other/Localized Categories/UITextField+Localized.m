//
//  UITextField+Localized.m
//  GeekNavi
//
//  Created By GeekNavi on 5/16/16.
//
//

#import "UITextField+Localized.h"

@implementation UITextField (Localized)
-(void)setTextfield:(NSString *)aText{
    [self setPlaceholder:NSLocalizedString(aText, nil)];
}

@end
