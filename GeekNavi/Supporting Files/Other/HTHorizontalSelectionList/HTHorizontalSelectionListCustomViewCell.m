//
//  HTHorizontalSelectionListCustomViewCell.m
//  HTHorizontalSelectionList Example
//
//  Created by Erik Ackermann on 2/27/15.
//  Copyright (c) 2015 Hightower. All rights reserved.
//

#import "HTHorizontalSelectionListCustomViewCell.h"

@interface HTHorizontalSelectionListCustomViewCell ()

@end

@implementation HTHorizontalSelectionListCustomViewCell

@synthesize state = _state, badgeValue = _badgeValue;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _state = UIControlStateNormal;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    for (UIView *subview in [self.contentView subviews]) {
        [subview removeFromSuperview];
    }

    self.state = UIControlStateNormal;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.contentView layoutSubviews];
    [self.customView layoutSubviews];
}

#pragma mark - Custom Getters and Setters

- (void)setCustomView:(UIView *)customView insets:(UIEdgeInsets)insets {
    _customView = customView;
    customView.translatesAutoresizingMaskIntoConstraints = NO;

    if (customView) {
        [self.contentView addSubview:customView];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftInset-[customView]-rightInset-|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:@{@"leftInset" : @(insets.left),
                                                                                           @"rightInset" : @(insets.right)}
                                                                                   views:NSDictionaryOfVariableBindings(customView)]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topInset-[customView]-bottomInset-|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:@{@"topInset" : @(insets.top),
                                                                                           @"bottomInset" : @(insets.bottom)}
                                                                                   views:NSDictionaryOfVariableBindings(customView)]];
    }
}

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue;

    [self setNeedsLayout];
}

@end
