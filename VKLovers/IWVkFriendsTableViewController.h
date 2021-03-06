//
//  IWVkFriendsTableViewController.h
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWWebApiManager.h"

@interface IWVkFriendsTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, IWWebApiManagerDelegate>

- (void)showMatchViewWithConfession:(IWConfession *)confession;

@end
