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
#import "Friend.h"
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

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation IWVkFriendsTableViewController

- (NSManagedObjectContext *)context {
    if (!_context) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _context = [delegate managedObjectContext];
    }
    return _context;
}

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
    [self loadFriendsPhotos];
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

- (void)loadFriendsPhotos {
    for (int i = 0; i < self.friends.count; ++i) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *photo = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.friends[i][@"photo_50"]]];
                self.friends[i][@"avatar"] = photo;
            });
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:k_NotificationName_LoadPhoto object:nil];
}

-(void)handleLoadPhoto:(NSNotification *)notification {
    [self.tableView reloadData];
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
    
    if (self.friends[number][@"avatar"]) {
        cell.avatar.image = [UIImage imageWithData:self.friends[number][@"avatar"]];
    } else {
        //default image
    }
    
    [cell setupSegmentControlUsingConfessions:self.confessions];
    
    return cell;
}

/*
#pragma mark CoreData
- (void)coreDataAddFriends:(NSMutableArray *)friends {
    //toBase.choice =
    
    for (id friend in friends) {
        Friend *toBase = [NSEntityDescription insertNewObjectForEntityForName:k_Entity_Name_Friend inManagedObjectContext:self.context];
        toBase.name = [friend[@"first_name"] stringByAppendingFormat:@" %@", friend[@"last_name"]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *photo = [NSData dataWithContentsOfURL:[NSURL URLWithString:friend[@"photo_50"]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //                NSLog(@"%d"(malloc_size((__bridge const void *)(toBase.name)) + malloc_size((__bridge const void *)(photo))));
                toBase.avatar = photo;
                NSError *error = nil;
                [self.context save:&error];
                
            });
        });
    }
}

- (BOOL)coreDataIsEmptyForFriends {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:k_Entity_Name_Friend];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:k_Entity_Name_Friend inManagedObjectContext:self.context];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    if (!request) {
        NSLog(@"Fetch error: %@", error);
    }
    return results.count == 0;
}

- (NSArray *)coreDataAllFriends {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:k_Entity_Name_Friend];
    NSError *error = nil;
    
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    if (error != nil) {
        NSLog(@"Error with fetching all friends %@", error);
    }
    
    return results;
}

- (void)coreDataClearBase {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:k_Entity_Name_Friend inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [self.context deleteObject:managedObject];
//        NSLog(@"%@ object deleted", entityDescription);
    }
    if (![self.context save:&error]) {
        NSLog(@"Error with deleting base %@", error);
    }
}

*/
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
