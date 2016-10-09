//
//  HTHorizontalSelectionListLabelCell.m
//  HTHorizontalSelectionList Example
//
//  Created by Erik Ackermann on 2/26/15.
//  Copyright (c) 2015 Hightower. All rights reserved.
//

#import "HTHorizontalSelectionListLabelCell.h"

@interface HTHorizontalSelectionListLabelCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableDictionary *titleColorsByState;
@property (nonatomic, strong) NSMutableDictionary *titleFontsByState;

@end

@implementation HTHorizontalSelectionListLabelCell

@synthesize state = _state, badgeValue = _badgeValue;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:_titleLabel];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_titleLabel)]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_titleLabel)]];

        _titleColorsByState = [NSMutableDictionary dictionary];
        _titleColorsByState[@(UIControlStateNormal)] = [UIColor blackColor];

        _titleFontsByState = [NSMutableDictionary dictionary];
        _titleFontsByState[@(UIControlStateNormal)] = [UIFont systemFontOfSize:13];

        _state = UIControlStateNormal;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.title = nil;
    self.titleColorsByState = [NSMutableDictionary dictionary];
    self.titleColorsByState[@(UIControlStateNormal)] = [UIColor blackColor];
    self.titleFontsByState = [NSMutableDictionary dictionary];
    self.titleFontsByState[@(UIControlStateNormal)] = [UIFont systemFontOfSize:13];
    self.state = UIControlStateNormal;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.contentView layoutSubviews];
    [self.titleLabel layoutSubviews];
}

#pragma mark - Public Methods

+ (CGSize)sizeForTitle:(NSString *)title withFont:(UIFont *)font {
    CGRect titleRect = [title boundingRectWithSize:CGSizeMake(FLT_MAX, FLT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : font}
                                           context:nil];

    return CGSizeMake(titleRect.size.width,
                      titleRect.size.height);
}

#pragma mark - Custom Getters and Setters

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue;

    [self setNeedsLayout];
}

- (void)setState:(UIControlState)state {
    _state = state;

    [self updateTitleColor];
    [self updateTitleFont];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    self.titleColorsByState[@(state)] = color;

    [self updateTitleColor];
}

- (void)setTitleFont:(UIFont *)font forState:(UIControlState)state {
    self.titleFontsByState[@(state)] = font;

    [self updateTitleFont];
}

#pragma mark - Private Methods

- (void)updateTitleColor {
    self.titleLabel.textColor = self.titleColorsByState[@(self.state)] ?: self.titleColorsByState[@(UIControlStateNormal)];
}

- (void)updateTitleFont {
    self.titleLabel.font = self.titleFontsByState[@(self.state)] ?: self.titleFontsByState[@(UIControlStateNormal)];
}

@end
