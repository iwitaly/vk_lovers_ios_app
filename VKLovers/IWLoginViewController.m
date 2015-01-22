//
//  IWLoginViewController.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWLoginViewController.h"
#import "IWVkManager.h"

@interface IWLoginViewController ()

@end

@implementation IWLoginViewController

- (IBAction)loginWithVK {
    [[IWVkManager sharedManager] login];
}


@end
