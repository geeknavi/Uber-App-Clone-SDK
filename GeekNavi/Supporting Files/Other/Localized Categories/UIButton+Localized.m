//
//  UIButton+Localized.m
//  GeekNavi
//
//  Created By GeekNavi on 5/16/16.
//
//

#import "UIButton+Localized.h"

@implementation UIButton (Localized)

-(void)setButton:(NSString *)aText{
    [self setTitle:NSLocalizedString(aText, nil) forState:UIControlStateNormal];
}
@end
