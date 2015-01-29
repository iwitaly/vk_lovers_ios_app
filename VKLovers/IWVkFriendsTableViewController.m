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
@property BOOL didSelectAll;

@end

@implementation IWVkFriendsTableViewController

- (NSMutableArray *)filteredFriends {
    if (!_filteredFriends) {
        _filteredFriends = [NSMutableArray new];
    }
    return _filteredFriends;
}

#pragma mark Controller lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[IWVkManager sharedManager] validVKSession]) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle:nil];
        IWLoginViewController *loginVc = (IWLoginViewController *)[mainStoryboard
                                                                   instantiateViewControllerWithIdentifier:kLoginViewController];
        [self presentViewController:loginVc animated:NO completion:nil];
        
    } else {
        [self loadData];
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
    [self loadData];
    [sender endRefreshing];
}

- (void)addNotificationsObservers {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(liftChosenFriendsUp)
     name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotificationsObservers];
    self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
    [self addRefreshControl];
    [IWWebApiManager sharedManager].webManagerDelegate = self;
//    [self addSearchController];
    self.tableView.allowsSelection = NO;
}

#pragma mark Loading

- (void)loadData {
    //load confessions from server
    [[IWWebApiManager sharedManager] getWhoConfessionListForCurrentUserWithCompletion:^(NSMutableArray *response) {
        self.confessions = response;
    }];
    
    //got friends from server
    [[IWVkManager sharedManager] loadFriendsForCurrentUserWithCompletion:^(NSMutableArray *response) {
        self.friends = response;
        [self liftChosenFriendsUp];
    }];
}


#pragma mark Actions

- (void)liftChosenFriendsUp {
    if (self.friends && self.confessions) {
        [self sortArrayOfFriendsInOrderOfArrayOfConfessions];
    }
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

- (IBAction)disableDidSelectALlOnTouch {
    self.didSelectAll = NO;
}

- (IBAction)sendConfessionsToAllUsers:(UIBarButtonItem *)sender {
    NSMutableArray *confs = [NSMutableArray new];
    int selectedIndex = sender.tag;
    ConfessionType type = -1;
    if (self.confessions.count) {
        type = ((IWConfession *)self.confessions[0]).type;
    }
    
    [[IWWebApiManager sharedManager].confessions removeAllObjects];
    
    if (self.didSelectAll == YES && selectedIndex == type) {//All was selected -> DELETE them or PUT
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
        
        self.didSelectAll = YES;
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
    [cell updateCellWithData:data withNumber:number asyncUpdateOriginalCell:^IWVkPersonTableViewCell *{
        return (id)[tableView cellForRowAtIndexPath:indexPath];
    }];    
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
