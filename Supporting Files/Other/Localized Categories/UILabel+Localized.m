//
//  UILabel+Localized.m
//  GeekNavi
//
//  Created By GeekNavi on 5/16/16.
//
//

#import "UILabel+Localized.h"

@implementation UILabel (Localized)

-(void)setLabel:(NSString *)aText{
    [self setText:NSLocalizedString(aText, nil)];
}

@end
