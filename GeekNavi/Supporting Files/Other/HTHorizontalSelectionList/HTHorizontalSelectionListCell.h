//
//  HTHorizontalSelectionListCell.h
//  HTHorizontalSelectionList Example
//
//  Created by Erik Ackermann on 2/27/15.
//  Copyright (c) 2015 Hightower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HTHorizontalSelectionListCell <NSObject>

@property (nonatomic) UIControlState state;

@property (nonatomic, strong) NSString *badgeValue;

@end
