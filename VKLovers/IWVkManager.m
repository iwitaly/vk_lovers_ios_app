//
//  IWVkManager.m
//  VKLovers
//
//  Created by Vitaly Davydov on 19/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "AppDelegate.h"
#import "IWVkManager.h"
#import "IWWebApiManager.h"

#define VK_APP_ID @"4736584"
#define NEXT_CONTROLLER_SEGUE_ID @"START_WORK"
#define k_Notification_Recieved_token @"k_Notification_Recieved_token"
#define kMainViewController @"kMainViewController"

@interface IWVkManager()

@end

@implementation IWVkManager 

- (NSString *)currentUserVkId {
    if (!_currentUserVkId) {
        _currentUserVkId = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentUserVkID"];
    }
    return _currentUserVkId;
}

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
                          get:@{VK_API_FIELDS : @"id,first_name,last_name,sex,photo_100", VK_API_ORDER : @"hints"}];
    return friends;
}

- (void)login {
    [VKSdk authorize:@[VK_PER_EMAIL, VK_PER_PAGES, VK_PER_WALL] revokeAccess:YES];
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
    UINavigationController *main = ((UINavigationController *)delegate.window.rootViewController).viewControllers[0];
    [main.presentedViewController presentViewController:controller animated:YES completion:nil];
}

/**
 Notifies delegate about receiving new access token
 @param newToken new token for API requests
 */

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSUserDefaults standardUserDefaults] setObject:newToken.userId forKey:@"CurrentUserVkID"];
    //send basic info to server
    [[[VKApi users] get:@{VK_API_FIELDS : @"contacts"}] executeWithResultBlock:^(VKResponse *response) {
        NSString *mobile = response.json[0][@"mobile_phone"];
        NSString *email = newToken.email == nil ? @"" : newToken.email;
        NSString *vkId = newToken.userId;
        
        IWUser *currentUser = [IWUser userWithVkId:vkId mobile:mobile email:email];
        [[IWWebApiManager sharedManager] postUser:currentUser withCompletion:^{
            [[IWWebApiManager sharedManager] postDeviceId];
        }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Getting users unfo error %@", error);
    }];
    
    UINavigationController *main = ((UINavigationController *)delegate.window.rootViewController).viewControllers[0];
    [main dismissViewControllerAnimated:YES completion:nil];
}

/**
 Load friends for current users sex
 */

- (NSMutableArray *)filterFriends:(NSArray *)friends bySex:(NSNumber *)sex {
    NSMutableArray *newArray = [NSMutableArray new];
    NSNumber *sexToShow = (sex.integerValue == 2) ? @1 : @2;
    sexToShow = !sex ? @0 : sexToShow;
    
    if (sexToShow.integerValue) {
        for (NSDictionary *friend in friends) {
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
    
    return newArray;
}

- (void)loadFriendsForCurrentUserWithCompletion:(IWFriendsBlock)block {
    //ask for users friends
    [[IWVkManager allFriends] executeWithResultBlock:^(VKResponse *response) {
        NSArray *friends = response.json[@"items"];
        
        //ask for users sex
        [[IWVkManager info] executeWithResultBlock:^(VKResponse *response) {
            NSMutableArray *filteredFriends = [self filterFriends:friends bySex:response.json[0][@"sex"]];
            block(filteredFriends);
        } errorBlock:^(NSError *error) {
            NSLog(@"Error with getting users info %@", error);
        }];
    } errorBlock:^(NSError *error) {
        NSLog(@"Error with loading friend list %@", error.description);
    }];
}

@end
