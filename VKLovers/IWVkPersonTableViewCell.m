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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)chooseFriend:(IWSegmentControl *)segmentControl {
    int selectedIndex = segmentControl.selectedSegmentIndex;
    int previousIndex = segmentControl.previousSelectedIndex;
//    NSLog(@"%d", selectedIndex);

    NSString *toWhoVkId = self.usersInfo[@"id"];
    //manage different cases:
    //prev == -1 and selected != -1 -> POST new
    //prev != -1 and selected != prev -> PUT
    //prev != -1 and selected == prev -> DELETE
    IWConfession *newConfession = [IWConfession confessionWithWhoVkId:[[IWVkManager sharedManager] currentUserVkId]
                                                            toWhoVkId:toWhoVkId
                                                                 type:selectedIndex];
    if (previousIndex == IndexTypeNothing && selectedIndex != IndexTypeNothing) {
        //post
        [[IWWebApiManager sharedManager] postConfession:newConfession];
    }
    if (previousIndex != IndexTypeNothing && selectedIndex != IndexTypeNothing) {
        //put
        [[IWWebApiManager sharedManager] putConfession:newConfession];

    }
    if (previousIndex != IndexTypeNothing && selectedIndex == IndexTypeNothing) {
//        delete
        [[IWWebApiManager sharedManager] deleteConfession:newConfession];
    }

    segmentControl.previousSelectedIndex = selectedIndex;
}

@end
