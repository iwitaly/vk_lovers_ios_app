//
//  IWVkPersonTableViewCell.h
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWSegmentControl.h"

#define k_NotificationName_DisableAllFriendsSegment @"k_NotificationName_DisableAllFriendsSegment"

@class IWVkPersonTableViewCell;

typedef NS_ENUM(NSInteger, IndexType) {
    IndexTypeNothing = -1,
    IndexTypeDate = 0,
    IndexTypeSex = 1
};

typedef IWVkPersonTableViewCell* (^IWVkPersonTableViewCellBlock)(void);

@interface IWVkPersonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet IWSegmentControl *choice;
@property (weak, nonatomic) NSDictionary *usersInfo;
@property (weak, nonatomic) NSMutableArray *confessions;

- (void)chooseFriend:(IWSegmentControl *)segmentControl;
- (void)setupSegmentControlUsingConfessions:(NSArray *)confessions;

- (void)updateCellWithData:(NSArray *)data withNumber:(NSUInteger)number asyncUpdateOriginalCell:(IWVkPersonTableViewCellBlock)block;

@end
