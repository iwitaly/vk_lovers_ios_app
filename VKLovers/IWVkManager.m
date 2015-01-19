//
//  IWVkManager.m
//  VKLovers
//
//  Created by Vitaly Davydov on 19/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "AppDelegate.h"
#import "IWVkManager.h"

#define VK_APP_ID @"4736584"
#define NEXT_CONTROLLER_SEGUE_ID @"START_WORK"
#define k_Notification_Recieved_token @"k_Notification_Recieved_token"

@implementation IWVkManager 

+ (instancetype)sharedManager {
    static IWVkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        [VKSdk initializeWithDelegate:self andAppId:VK_APP_ID];
    }
    return self;
}

//info about current user
+ (VKRequest *)info {
    VKRequest *user = [[VKApi users] get:@{VK_API_FIELDS : @"id,contacts,sex"}];
    return user;
}

//info about his friends: name, last name, sex, photo 50x50
+ (VKRequest *)allFriends {
    VKRequest *friends = [[VKApi friends]
                          get:@{VK_API_FIELDS : @"id,first_name,last_name,sex,photo_50"}];
    return friends;
}

- (void)login {
    [VKSdk authorize:@[VK_PER_EMAIL, VK_PER_PAGES] revokeAccess:YES];
}

- (BOOL)validVKSession {
    return [VKSdk wakeUpSession];
}

#pragma mark VK_SDK_Delegation
/**
 Calls when user must perform captcha-check
 @param captchaError error returned from API. You can load captcha image from <b>captchaImg</b> property.
 After user answered current captcha, call answerCaptcha: method with user entered answer.
 */
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    //
}

/**
 Notifies delegate about existing token has expired
 @param expiredToken old token that has expired
 */
- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self login];
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
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

/**
 Notifies delegate about receiving new access token
 @param newToken new token for API requests
 */
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
//    [[NSNotificationCenter defaultCenter] postNotificationName:k_Notification_Recieved_token object:nil];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [delegate.window.rootViewController performSegueWithIdentifier:NEXT_CONTROLLER_SEGUE_ID sender:nil];
  
  
  // The better way, I think
  // но вообще не так все надо делать, не такая иерархия контроллеров. Спроси как лучше потом
  UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"kMainViewController"];
  delegate.window.rootViewController = vc;
  
}

@end
