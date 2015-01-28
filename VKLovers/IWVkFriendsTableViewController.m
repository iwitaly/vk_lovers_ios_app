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
#import "KLCPopup.h"
#import "IWMatchView.h"
#import "IWLoginViewController.h"

#define kLoginViewController @"kLoginViewController"

#define k_Reusable_Cell_Identifier @"VK_FRIEND"

@interface IWVkFriendsTableViewController ()
{
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *filteredFriends;
@property (nonatomic, strong) NSMutableArray *confessions;
@property (weak, nonatomic) IBOutlet IWSegmentControl *allFriendsSegment;

@end

@implementation IWVkFriendsTableViewController

- (NSMutableArray *)filteredFriends {
    if (!_filteredFriends) {
        _filteredFriends = [[NSMutableArray alloc] init];
    }
    return _filteredFriends;
}

#pragma mark Controller lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleConfessions:)
     name:k_NotificationGotConfessionsFromServer object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleDisabling)
     name:k_NotificationName_DisableAllFriendsSegment object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(liftChosenFriendsUp)
     name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (![[IWVkManager sharedManager] validVKSession]) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle:nil];
        IWLoginViewController *loginVc = (IWLoginViewController *)[mainStoryboard
                                                                    instantiateViewControllerWithIdentifier:kLoginViewController];
        [self presentViewController:loginVc animated:NO completion:nil];
    } else {
        [self loadFriendList];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
}

- (void)addSearchController {
//    searchBar = [[UISearchBar alloc] initWithFrame:self.navigationItem.titleView.frame];
//    self.navigationItem.titleView = searchBar;
//    searchBar.delegate = self;
//    
//    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
//                                                                                    contentsController:self];
//    searchDisplayController.delegate = self;
//    searchDisplayController.searchResultsDataSource = self;
//    searchDisplayController.searchResultsDelegate = self;
////    [self.searchDisplayController.searchResultsTableView registerClass:[IWVkPersonTableViewCell class] forCellReuseIdentifier:@"VK_FRIEND"];
//    searchDisplayController.displaysSearchBarInNavigationBar = YES;
}

- (void)addRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(UIRefreshControl *)sender {
    [self loadFriendList];
    [sender endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
    [self addRefreshControl];
    [IWWebApiManager sharedManager].webManagerDelegate = self;
//    [self addSearchController];
    self.tableView.allowsSelection = NO;
}

#pragma mark Loading

- (void)filterFriendsBySex:(NSNumber *)sex {
    NSMutableArray *newArray = [NSMutableArray new];
    NSNumber *sexToShow = (sex.integerValue == 2) ? @1 : @2;
    sexToShow = !sex ? @0 : sexToShow;
    
    if (sexToShow.integerValue) {
        for (NSDictionary *friend in self.friends) {
            if ([friend[@"sex"] isEqualToNumber:sexToShow]) {
                //add new field name to all friends
                NSMutableDictionary *mutableFriend = [friend mutableCopy];
                mutableFriend[@"name"] = [friend[@"first_name"] stringByAppendingFormat:@" %@",friend[@"last_name"]];
                [newArray addObject:mutableFriend];
            }
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No sex!" message:@"No sex mentioned in your profile" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
    self.friends = newArray;
    [self liftChosenFriendsUp];
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
        self.confessions = [[NSMutableArray alloc] init];
    }
}

- (void)loadFriendList {
    //load confessions from server, handle notification
    [[IWWebApiManager sharedManager] getWhoConfessionListForCurrentUser];

    //got friends from server, handle notification
    [[IWVkManager allFriends] executeWithResultBlock:^(VKResponse *response) {
        self.friends = response.json[@"items"];
        [self loadUsersSex];
    } errorBlock:^(NSError *error) {
        NSLog(@"Error with loading friend list %@", error.description);
    }];
}

- (void)loadUsersSex {
    [[IWVkManager info] executeWithResultBlock:^(VKResponse *response) {
        [self filterFriendsBySex:response.json[0][@"sex"]];
    } errorBlock:^(NSError *error) {
        NSLog(@"Error with getting users info %@", error);
    }];
}


#pragma mark Actions

- (void)liftChosenFriendsUp {
    if (!self.friends || !self.confessions) {
        return;
    }
    [self sortArrayOfFriendsInOrderOfArrayOfConfessions];
    [self.tableView reloadData];
}

- (void)sortArrayOfFriendsInOrderOfArrayOfConfessions {
    NSMutableArray *toWhoVkIds = [[NSMutableArray alloc] init];
    for (id obj in self.confessions) {
        IWConfession *conf = nil;
        if ([obj isKindOfClass:[IWConfession class]]) {
            conf = (IWConfession *)obj;
        } else {
            [NSException raise:@"Wrong object during sorting" format:nil];
        }
        
        [toWhoVkIds addObject:conf.to_who_vk_id];
    }
    
    NSMutableArray *buffArray = [[NSMutableArray alloc] init];
    
    for (id obj in self.friends) {
        NSDictionary *friend = nil;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            friend = (NSDictionary *)obj;
        } else {
            [NSException raise:@"Wrong object during sorting" format:nil];
        }
        
        if ([toWhoVkIds containsObject:[NSString stringWithFormat:@"%@", friend[@"id"]]]) {
            [buffArray insertObject:friend atIndex:0];
        } else {
            [buffArray addObject:friend];
        }
    }
    self.friends = buffArray;
}

//disable segment control for choosing all friends
- (void)handleDisabling {
    self.allFriendsSegment.selectedSegmentIndex = IndexTypeNothing;
}

- (IBAction)sendConfessionsToAllUsers:(IWSegmentControl *)sender {
    NSMutableArray *confs = [[NSMutableArray alloc] init];
    int selectedIndex = sender.selectedSegmentIndex;
    
    self.confessions = [[NSMutableArray alloc] init];
    
    if (selectedIndex == IndexTypeNothing) {
        [[IWWebApiManager sharedManager] removeConfessions:self.confessions];
    } else {
        for (NSDictionary *dics in self.friends) {
            NSString *whoVkId = [NSString stringWithFormat:@"%@", [IWVkManager sharedManager].currentUserVkId];
            NSString *toWhoVkId = [NSString stringWithFormat:@"%@", dics[@"id"]];
            IWConfession *newConfession = [IWConfession confessionWithWhoVkId:whoVkId
                                                                    toWhoVkId:toWhoVkId
                                                                         type:selectedIndex];
            NSDictionary *params = @{@"who_vk_id" : whoVkId,
                                     @"to_who_vk_id" : toWhoVkId,
                                     @"type" : @(selectedIndex)};
            [confs addObject:params];
            [self.confessions addObject:newConfession];
        }
        [[IWWebApiManager sharedManager] postArrayOfConfessions:confs];
    }
    [self.tableView reloadData];
}

- (IBAction)shareVk {
    VKShareDialogController * shareDialog = [VKShareDialogController new];
    shareDialog.text = @"This post created using #vksdk #ios";
    shareDialog.shareLink = [[VKShareLink alloc] initWithTitle:@"Super puper link, but nobody knows" link:[NSURL URLWithString:@"https://vk.com/dev/ios_sdk"]];
    [shareDialog setCompletionHandler:^(VKShareDialogControllerResult result) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:shareDialog animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (tableView == self.tableView) ? self.friends.count : self.filteredFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IWVkPersonTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:k_Reusable_Cell_Identifier];

    if (tableView == self.tableView) {
        [self updateCell:cell forCellAtIndexPath:indexPath withData:self.friends forTableView:tableView];
    } else {
        //filtered content
        [self updateCell:cell forCellAtIndexPath:indexPath withData:self.filteredFriends forTableView:tableView];
    }
    
    return cell;
}

- (void)updateCell:(IWVkPersonTableViewCell *)cell forCellAtIndexPath:(NSIndexPath *)indexPath withData:(NSArray *)data forTableView:(UITableView *)tableView {
    NSUInteger number = indexPath.row;
    
//    [cell.choice removeTarget:cell action:@selector(chooseFriend:) forControlEvents:UIControlEventValueChanged];
//    [cell.choice addTarget:cell action:@selector(chooseFriend:) forControlEvents:UIControlEventValueChanged];
    
    cell.name.text = data[number][@"name"];
    cell.usersInfo = data[number];
    cell.confessions = self.confessions;
    
    NSString *identifier = [NSString stringWithFormat:@"Cell%d", number];
    
    if (data[number][@"avatar"]) {
        cell.avatar.image = data[number][@"avatar"];
    } else {
        char const *s = [identifier  UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(s, 0);
        
        dispatch_async(queue, ^{
            NSData *photo = [NSData dataWithContentsOfURL:[NSURL URLWithString:data[number][@"photo_100"]]];
            UIImage *img = [UIImage imageWithData:photo];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([tableView indexPathForCell:cell].row == number) {
                    data[number][@"avatar"] = img;
                    cell.avatar.image = data[number][@"avatar"];
                }
            });
        });
    }
    
    [cell setupSegmentControlUsingConfessions:self.confessions];
}

#pragma mark - Content Filtering

- (void)filterFriendsForString:(NSString *)searchString {
    [self.filteredFriends removeAllObjects];
    for (id obj in self.friends) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *friend = obj;
            NSString *name = friend[@"name"];
            if ([name rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [self.filteredFriends addObject:friend];
            }
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterFriendsForString:searchString];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    [tableView registerClass:[IWVkPersonTableViewCell class] forCellReuseIdentifier:k_Reusable_Cell_Identifier];
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.tableView reloadData];
}

#pragma mark - IWWebApiManagerDelegate methods

- (void)showMatchViewWithConfession:(IWConfession *)confession {
    IWMatchView *contentView = [[NSBundle mainBundle] loadNibNamed:@"IWMatchView" owner:self options:nil][0];
//    contentView.translatesAutoresizingMaskIntoConstraints = NO;
//
//    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[contentView(==200)]"
//                                            options: 0
//                                            metrics:nil
//                                              views:@{@"contentView" : contentView}]];
    contentView.matchLabel.text = [NSString stringWithFormat:@"You match with user %@", confession.to_who_vk_id];
    KLCPopup *popUp = [KLCPopup popupWithContentView:contentView];
    [popUp show];
}

- (void)didEndPostConfession:(IWConfession *)confession withResult:(BOOL)is_completed {
    if (is_completed) {
        [self showMatchViewWithConfession:confession];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
