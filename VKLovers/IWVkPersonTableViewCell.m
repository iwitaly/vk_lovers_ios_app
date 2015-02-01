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
//    NSLog(@"count %@", self.confessions);    
    if (selectedIndex == IndexTypeNothing) {
        //delete
        [[IWWebApiManager sharedManager] deleteConfession:newConfession];
        [self.confessions deleteConfessionWithWhoVkId:whoVKid toWhoVkId:toWhoVkId];
    } else {
        //post or put
        [[IWWebApiManager sharedManager] postConfession:newConfession];
        [self.confessions changeConfessionTypeWithWhoVkId:whoVKid toWhoVkId:toWhoVkId andType:selectedIndex];
    }
    
//    NSLog(@"count %@", self.confessions);
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

- (void)updateCellWithData:(NSArray *)data withNumber:(NSUInteger)number asyncUpdateOriginalCell:(IWVkPersonTableViewCellBlock)bloc {
    self.name.text = data[number][@"name"];
    self.usersInfo = data[number];
    self.confessions = [IWWebApiManager sharedManager].confessions;
    
    NSString *identifier = [NSString stringWithFormat:@"Cell%d", number];
    
    if (data[number][@"avatar"]) {
        self.avatar.image = data[number][@"avatar"];
    } else {
        char const *s = [identifier  UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(s, 0);
        
        dispatch_async(queue, ^{
            NSData *photo = [NSData dataWithContentsOfURL:[NSURL URLWithString:data[number][@"photo_100"]]];
            UIImage *img = [UIImage imageWithData:photo];
            dispatch_async(dispatch_get_main_queue(), ^{
                IWVkPersonTableViewCell *originalCell = (id)bloc();
                data[number][@"avatar"] = img;
                originalCell.avatar.image = data[number][@"avatar"];
                originalCell.avatar.layer.cornerRadius = originalCell.avatar.frame.size.height / 2;
                originalCell.avatar.layer.masksToBounds = YES;
                originalCell.avatar.layer.borderWidth = 0;
            });
        });
    }
    [self setupSegmentControlUsingConfessions:self.confessions];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatar.image = nil;
    self.name.text = nil;
    self.choice.selectedSegmentIndex = -1;
}

@end
