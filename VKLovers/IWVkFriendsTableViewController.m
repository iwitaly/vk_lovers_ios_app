//
//  IWVkFriendsTableViewController.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWVkFriendsTableViewController.h"
#import "IWVkManager.h"
#import "IWVkPersonTableViewCell.h"
#import "AppDelegate.h"
#import "IWUser.h"
#import "IWWebApiManager.h"
#import <malloc/malloc.h>

#define k_NotificationName_UsersLoaded @"k_NotificationName_UsersLoaded"
#define k_NotificationName_UserInfo @"k_NotificationName_UserInfo"
#define k_NotificationName_LoadPhoto @"k_NotificationName_LoadPhoto"
#define k_Entity_Name_Friend @"Friend"

#define k_Segue_Login @"LOGIN"

@interface IWVkFriendsTableViewController ()

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *confessions;

@end

@implementation IWVkFriendsTableViewController

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handlerFriends:)
     name:k_NotificationName_UsersLoaded object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleUser:)
     name:k_NotificationName_UserInfo object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleConfessions:)
     name:k_NotificationGotConfessionsFromServer object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleLoadPhoto:)
     name:k_NotificationName_LoadPhoto object:nil];
    
    if (![[IWVkManager sharedManager] validVKSession]) {
        [self performSegueWithIdentifier:k_Segue_Login sender:nil];
    } else {
        [self loadFriendList];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
}

- (void)handlerFriends:(NSNotification *)jsonData {
    self.friends = jsonData.object;
    //filter by sex, send notification
    [self filterFriends];
}

- (void)handleUser:(NSNotification *)userInfo {
    NSNumber *sex = userInfo.object;
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    NSNumber *sexToShow = (sex.integerValue == 2) ? @1 : @2;
    sexToShow = !sex ? @0 : sexToShow;
    
    if (sexToShow.integerValue) {
        for (id friend in self.friends) {
            if ([friend[@"sex"] isEqualToNumber:sexToShow]) {
                [newArray addObject:[NSMutableDictionary dictionaryWithDictionary:friend]];
            }
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No sex!" message:@"No sex mentioned in your profile" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
    self.friends = newArray;
    
#warning Test send all users
//    [self sendConfessionsToAllUsers];
    
    [self.tableView reloadData];
}

- (void)sendConfessionsToAllUsers {
    NSMutableArray *confs = [[NSMutableArray alloc] init];
    for (NSDictionary *dics in self.friends) {
        NSString *whoVkId = [NSString stringWithFormat:@"%@", [IWVkManager sharedManager].currentUserVkId];
        NSString *toWhoVkId = [NSString stringWithFormat:@"%@", dics[@"id"]];
//        IWConfession *conf = [IWConfession confessionWithWhoVkId:whoVkId
//                                                       toWhoVkId:toWhoVkId type:ConfessionTypeDate];
        NSDictionary *params = @{@"who_vk_id" : whoVkId,
                                 @"to_who_vk_id" : toWhoVkId,
                                 @"type" : @(ConfessionTypeDate)};
        [confs addObject:params];
    }
    
    [[IWWebApiManager sharedManager] postArrayOfConfessions:confs];
}

//got notifications from server
- (void)handleConfessions:(NSNotification *)notification {
    if (((NSArray *)notification.object).count) {
        self.confessions = [NSMutableArray arrayWithArray:notification.object];
        for (int i = 0; i < self.confessions.count; ++i) {
            NSString *whoVKid = [NSString stringWithFormat:@"%@", self.confessions[i][@"who_vk_id"]];
            NSString *toWhoVKid = [NSString stringWithFormat:@"%@", self.confessions[i][@"to_who_vk_id"]];
            IWConfession *newConfession = [IWConfession confessionWithWhoVkId:whoVKid
                                                                    toWhoVkId:toWhoVKid
                                                                         type:(ConfessionType)[self.confessions[i][@"type"] integerValue]];
            self.confessions[i] = newConfession;
        }
    } else {
        self.confessions = [NSMutableArray arrayWithArray:@[]];
    }
}

- (void)loadFriendList {
    //load confessions from server, handle notification
    [[IWWebApiManager sharedManager] getWhoConfessionListForCurrentUser];
    
    //got friends from server, handle notification
    [[IWVkManager allFriends] executeWithResultBlock:^(VKResponse *response) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:k_NotificationName_UsersLoaded object:response.json[@"items"]];
    } errorBlock:^(NSError *error) {
        NSLog(@"Error with loading friend list %@", error.description);
    }];
}

- (void)filterFriends {
    [[IWVkManager info] executeWithResultBlock:^(VKResponse *response) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:k_NotificationName_UserInfo object:response.json[0][@"sex"]];
    } errorBlock:^(NSError *error) {
        NSLog(@"Error with getting users info %@", error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IWVkPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VK_FRIEND" forIndexPath:indexPath];
    NSUInteger number = indexPath.row;
    
//    [cell.choice removeTarget:cell action:@selector(chooseFriend:) forControlEvents:UIControlEventValueChanged];
    [cell.choice addTarget:cell action:@selector(chooseFriend:) forControlEvents:UIControlEventValueChanged];
    
    cell.name.text = [self.friends[number][@"first_name"] stringByAppendingFormat:@" %@",self.friends[number][@"last_name"]];
    cell.usersInfo = self.friends[number];
    cell.confessions = self.confessions;
    
    NSString *identifier = [NSString stringWithFormat:@"Cell%d", number];
    
    if (self.friends[number][@"avatar"]) {
        cell.avatar.image = self.friends[number][@"avatar"];
    } else {
        char const *s = [identifier  UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(s, 0);

        dispatch_async(queue, ^{
            NSData *photo = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.friends[number][@"photo_50"]]];
            UIImage *img = [UIImage imageWithData:photo];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([tableView indexPathForCell:cell].row == number) {
                    self.friends[number][@"avatar"] = img;
                    cell.avatar.image = self.friends[number][@"avatar"];
                }
            });
        });
    }
    
    [cell setupSegmentControlUsingConfessions:self.confessions];
    
    return cell;
}

@end
