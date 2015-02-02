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

- (IBAction)chooseFriendButton:(UIButton *)sender {
    int selectedIndex = sender.tag;
    self.buttonsContainerView.selectedButton = selectedIndex;
    
    NSString *toWhoVkId = [NSString stringWithFormat:@"%@", self.usersInfo[@"id"]];
    NSString *whoVKid = [NSString stringWithFormat:@"%@", [[IWVkManager sharedManager] currentUserVkId]];
    
    IWConfession *newConfession = [IWConfession confessionWithWhoVkId:whoVKid
                                                            toWhoVkId:toWhoVkId
                                                                 type:selectedIndex];
    if (self.buttonsContainerView.selectedButton == SelectedButtonNone) {
        //post or put
        [[IWWebApiManager sharedManager] deleteConfession:newConfession];
        [self.confessions deleteConfessionWithWhoVkId:whoVKid toWhoVkId:toWhoVkId];
    } else {
        [[IWWebApiManager sharedManager] postConfession:newConfession];
        [self.confessions changeConfessionTypeWithWhoVkId:whoVKid toWhoVkId:toWhoVkId andType:selectedIndex];
    }
}

- (void)setupButtonsUsingConfessions:(NSArray *)confessions {
    NSArray *filtered = [confessions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"to_who_vk_id = %@",
                         [NSString stringWithFormat:@"%@", self.usersInfo[@"id"]]]];
                                                                  
    if (filtered.count) {
        IWConfession *confession = filtered.firstObject;
        self.buttonsContainerView.selectedButton = confession.type;
    }
    
    /*
    for (IWConfession *confession in confessions) {
        NSString *number = [NSString stringWithFormat:@"%@", self.usersInfo[@"id"]];
        
        if ([confession.to_who_vk_id isEqualToString:number]) {
            self.buttonsContainerView.selectedButton = confession.type;
            return;
        }
    }
    */
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
    [self setupButtonsUsingConfessions:self.confessions];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatar.image = nil;
    self.name.text = nil;
    self.buttonsContainerView.selectedButton = SelectedButtonNone;
}

@end
