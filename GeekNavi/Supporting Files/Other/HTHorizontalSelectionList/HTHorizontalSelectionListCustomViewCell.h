//
//  HTHorizontalSelectionListCustomViewCell.h
//  HTHorizontalSelectionList Example
//
//  Created by Erik Ackermann on 2/27/15.
//  Copyright (c) 2015 Hightower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTHorizontalSelectionListCell.h"

@interface HTHorizontalSelectionListCustomViewCell : UICollectionViewCell <HTHorizontalSelectionListCell>

- (void)setCustomView:(UIView *)customView insets:(UIEdgeInsets)insets;

@property (nonatomic, strong) UIView *customView;

@end
