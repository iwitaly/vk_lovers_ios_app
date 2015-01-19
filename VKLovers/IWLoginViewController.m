//
//  IWLoginViewController.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWLoginViewController.h"
#import "IWVkManager.h"

#define VK_APP_ID @"4736584"
#define NEXT_CONTROLLER_SEGUE_ID @"START_WORK"
#define k_Notification_Recieved_token @"k_Notification_Recieved_token"

@interface IWLoginViewController ()

@end

@implementation IWLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startWork) name:k_Notification_Recieved_token object:nil];
}

- (void)startWork {
    [self performSegueWithIdentifier:NEXT_CONTROLLER_SEGUE_ID sender:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)loginWithVK {
    [[IWVkManager sharedManager] login];
}


@end
