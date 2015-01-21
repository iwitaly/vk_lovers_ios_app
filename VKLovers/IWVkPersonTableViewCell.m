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

@implementation IWVkPersonTableViewCell

- (void)awakeFromNib {
    self.choice.previousSelectedIndex = -1;
}

- (void)chooseFriend:(IWSegmentControl *)segmentControl {
    int selectedIndex = segmentControl.selectedSegmentIndex;
    int previousIndex = segmentControl.previousSelectedIndex;

    NSString *toWhoVkId = [NSString stringWithFormat:@"%@", self.usersInfo[@"id"]];
    //manage different cases:
    //prev == -1 and selected != -1 -> POST new
    //prev != -1 and selected != prev -> PUT
    //prev != -1 and selected == prev -> DELETE
    NSString *whoVKid = [NSString stringWithFormat:@"%@", [[IWVkManager sharedManager] currentUserVkId]];

    IWConfession *newConfession = [IWConfession confessionWithWhoVkId:whoVKid
                                                            toWhoVkId:toWhoVkId
                                                                 type:selectedIndex];
    
//    NSLog(@"count %@", self.confessions);
    if (previousIndex == IndexTypeNothing && selectedIndex != IndexTypeNothing) {
        //post
        [[IWWebApiManager sharedManager] postConfession:newConfession];
        [self.confessions addObject:newConfession];
        segmentControl.previousSelectedIndex = selectedIndex;
    }
    if (previousIndex != IndexTypeNothing && selectedIndex != IndexTypeNothing) {
        //put
        [[IWWebApiManager sharedManager] putConfession:newConfession];
        
        IWConfession *newConfessionUpdated = [IWConfession confessionWithWhoVkId:whoVKid
                                                                       toWhoVkId:toWhoVkId
                                                                            type:previousIndex];

        [self.confessions removeObject:newConfessionUpdated];
        [self.confessions addObject:newConfession];
    }
    if (previousIndex != IndexTypeNothing && selectedIndex == IndexTypeNothing) {
//        delete
        [[IWWebApiManager sharedManager] deleteConfession:newConfession];
        IWConfession *newConfessionUpdated = [IWConfession confessionWithWhoVkId:[[IWVkManager sharedManager] currentUserVkId]
                                                                       toWhoVkId:toWhoVkId
                                                                            type:self.choice.previousSelectedIndex];
        [self.confessions removeObject:newConfessionUpdated];
        segmentControl.previousSelectedIndex = selectedIndex;
    }
//    NSLog(@"count %@", self.confessions);
}

- (void)setupSegmentControlUsingConfessions:(NSArray *)confessions {
    for (IWConfession *confession in confessions) {
//        NSLog(@"%@", confession[@"to_who_vk_id"]);
//        NSLog(@"%@, %@", [[confession[@"to_who_vk_id"] class] description], [[self.usersInfo[@"id"] class] description]);
        NSString *number = [NSString stringWithFormat:@"%@", self.usersInfo[@"id"]];
//        NSLog(@"%@,%@", confession[@"to_who_vk_id"], number);
        
        if ([confession.to_who_vk_id isEqualToString:number]) {
            self.choice.selectedSegmentIndex = confession.type;
            self.choice.previousSelectedIndex = self.choice.selectedSegmentIndex;
            return;
        }
    }
    
//    NSLog(@"\n");
}

- (void)prepareForReuse {
    self.choice.previousSelectedIndex = self.choice.selectedSegmentIndex;
    self.choice.selectedSegmentIndex = -1;
}

@end
