//
//  IWVkFriendsTableViewController.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWVkFriendsTableViewController.h"
#import "IWVk.h"
#import "IWVkPersonTableViewCell.h"

#define k_NotificationName_UsersLoaded @"k_NotificationName_UsersLoaded"
#define k_NotificationName_UserInfo @"k_NotificationName_UserInfo"

@interface IWVkFriendsTableViewController ()

@property (nonatomic, strong) NSMutableArray *friends;

@end

@implementation IWVkFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handlerFriends:)
     name:k_NotificationName_UsersLoaded object:nil];
    
    [self loadFriendList];
}

- (void)handlerFriends:(NSNotification *)jsonData {
    self.friends = jsonData.object;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleUser:)
     name:k_NotificationName_UserInfo object:nil];

//    NSLog(@"%@", self.friends);
    [self filterFriends];
}

- (void)handleUser:(NSNotification *)userInfo {
    NSNumber *sex = userInfo.object;
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    if ([sex isEqualToNumber:@2]) {
        for (id friend in self.friends) {
            if (![friend[@"sex"] isEqualToNumber:@2]) {
                [newArray addObject:friend];
            }
        }
    }
    
    self.friends = newArray;
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadFriendList {
    [[IWVk allFriends] executeWithResultBlock:^(VKResponse *response) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:k_NotificationName_UsersLoaded object:response.json[@"items"]];
    } errorBlock:^(NSError *error) {
        NSLog(@"Error with loading friend list %@", error.description);
    }];
}

- (void)filterFriends {
    [[IWVk info] executeWithResultBlock:^(VKResponse *response) {
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
    
    cell.name.text = [self.friends[number][@"first_name"] stringByAppendingFormat:@" %@",self.friends[number][@"last_name"]];
    dispatch_async(dispatch_queue_create("ImageQueue", NULL), ^{
        cell.avatar.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.friends[number][@"photo_50"]]]];
    });
    
    return cell;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
