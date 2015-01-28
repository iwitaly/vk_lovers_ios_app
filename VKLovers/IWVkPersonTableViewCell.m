//
//  IWVkPersonTableViewCell.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWVkPersonTableViewCell.h"
#import "IWConfession.h"
#import "IWVkManager.h"
#import "IWWebApiManager.h"
#import "NSMutableArray+confessionManagment.h"

@interface IWVkPersonTableViewCell()


@end

@implementation IWVkPersonTableViewCell

- (void)awakeFromNib {
    self.name.adjustsFontSizeToFitWidth = YES;
}

- (IBAction)chooseFriend:(IWSegmentControl *)segmentControl {
    int selectedIndex = segmentControl.selectedSegmentIndex;

    NSString *toWhoVkId = [NSString stringWithFormat:@"%@", self.usersInfo[@"id"]];
    //manage different cases:
    //prev == -1 and selected != -1 -> POST new
    //prev != -1 and selected != prev -> PUT
    //prev != -1 and selected == prev -> DELETE
    NSString *whoVKid = [NSString stringWithFormat:@"%@", [[IWVkManager sharedManager] currentUserVkId]];

    IWConfession *newConfession = [IWConfession confessionWithWhoVkId:whoVKid
                                                            toWhoVkId:toWhoVkId
                                                                 type:selectedIndex];
    NSLog(@"count %@", self.confessions);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k_NotificationName_DisableAllFriendsSegment object:nil];
    
    if (selectedIndex == IndexTypeNothing) {
        //delete
        [[IWWebApiManager sharedManager] deleteConfession:newConfession];
        [self.confessions deleteConfessionWithWhoVkId:whoVKid toWhoVkId:toWhoVkId];
    } else {
        //post or put
        [[IWWebApiManager sharedManager] postConfession:newConfession];
        [self.confessions changeConfessionTypeWithWhoVkId:whoVKid toWhoVkId:toWhoVkId andType:selectedIndex];
    }
    
    NSLog(@"count %@", self.confessions);
}

- (void)setupSegmentControlUsingConfessions:(NSArray *)confessions {
    for (IWConfession *confession in confessions) {
        NSString *number = [NSString stringWithFormat:@"%@", self.usersInfo[@"id"]];
        
        if ([confession.to_who_vk_id isEqualToString:number]) {
            self.choice.selectedSegmentIndex = confession.type;
            return;
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatar.image = nil;
    self.choice.selectedSegmentIndex = -1;
}

@end
