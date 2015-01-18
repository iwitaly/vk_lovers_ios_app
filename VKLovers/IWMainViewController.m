//
//  IWMainViewController.m
//  VK Lovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWMainViewController.h"
#import "IWVk.h"
#import "IWVKResponse.h"

@interface IWMainViewController ()

@end

@implementation IWMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout:)];
    [self getUsersList];
    // Do any additional setup after loading the view.
}

- (void)logout:(id)sender {
    [VKSdk forceLogout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (void)getUsersList {
    //NSLog(@"%@", [VKSdk getAccessToken].email);
    [[IWVk allFriends] executeWithResultBlock:^(VKResponse *response) {
        //id data = [NSJSONSerialization JSONObjectWithData:response.json options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@", response.json[@"items"][0]);
    } errorBlock:nil];
}


@end
