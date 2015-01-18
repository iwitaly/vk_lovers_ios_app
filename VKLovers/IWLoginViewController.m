//
//  IWLoginViewController.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWLoginViewController.h"

#define VK_APP_ID @"4736584"
#define NEXT_CONTROLLER_SEGUE_ID @"START_WORK"

@interface IWLoginViewController ()

@end

@implementation IWLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [VKSdk initializeWithDelegate:self andAppId:VK_APP_ID];
    
    if ([VKSdk wakeUpSession]) {
        [self startWork];
    }
}

- (IBAction)loginWithVK {
    [VKSdk authorize:@[VK_PER_EMAIL, VK_PER_PAGES] revokeAccess:YES];
}

#pragma mark VK_SDK_Delegation
/**
 Calls when user must perform captcha-check
 @param captchaError error returned from API. You can load captcha image from <b>captchaImg</b> property.
 After user answered current captcha, call answerCaptcha: method with user entered answer.
 */
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    
}

/**
 Notifies delegate about existing token has expired
 @param expiredToken old token that has expired
 */
- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self loginWithVK];
}

/**
 Notifies delegate about user authorization cancelation
 @param authorizationError error that describes authorization error
 */
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [[[UIAlertView alloc] initWithTitle:nil
                                message:@"Access denied"
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

/**
 Pass view controller that should be presented to user. Usually, it's an authorization window
 @param controller view controller that must be shown to user
 */
- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

/**
 Notifies delegate about receiving new access token
 @param newToken new token for API requests
 */
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self startWork];
}


- (void)startWork {
    [self performSegueWithIdentifier:NEXT_CONTROLLER_SEGUE_ID sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
