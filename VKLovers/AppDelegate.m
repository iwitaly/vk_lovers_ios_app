//
//  AppDelegate.m
//  VK Lovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "AppDelegate.h"
#import "IWVkManager.h"
#import "IWWebApiManager.h"
#import "IWVkFriendsTableViewController.h"

#define kLoginViewController @"kLoginViewController"
#define kMainViewController @"kMainViewController"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    IWUser *vitaly = [IWUser userWithVkId:@"167211370" mobile:@"" email:@"iwitaly@me.com"];
//    IWUser *tumanov = [IWUser userWithVkId:@"tumanov" mobile:@"1213" email:@"tumanov@yandex.ru"];
//    IWConfession *confession = [IWConfession confessionWithWhoVkId:@"iwitaly" toWhoVkId:@"tumanov" type:ConfessionTypeDate];
//    [[IWWebApiManager sharedManager] postUser:vitaly];
//    [[IWWebApiManager sharedManager] postConfession:confession];
//    [[IWWebApiManager sharedManager] getWhoConfessionListForUser:confession];
//    [[IWWebApiManager sharedManager] getWhoConfessionListForUser:vitaly];
//    [[IWWebApiManager sharedManager] getConfessionFromUser:vitaly toUser:tumanov];
    
//    IWVkManager *vkManager = [IWVkManager sharedManager];
//    BOOL validVKSession = [vkManager validVKSession];
//    NSString *controllerToOpen = validVKSession ? kMainViewController : kLoginViewController;
//    self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:controllerToOpen];
//
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    } else {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    return YES;
}

//d65a3e0c15dfb6f8fd012a9f105475558710f137647e9fc60b16c14327776f71 – iPad Tuman

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken.description forKey:@"DeviceToken"];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Fetch handler");
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
    IWVkFriendsTableViewController *mainVc = (IWVkFriendsTableViewController *)[mainStoryboard
                                                               instantiateViewControllerWithIdentifier:kMainViewController];
    [mainVc showMatchViewWithConfession:[IWConfession confessionWithWhoVkId:
                                         userInfo[@"who_vk_id"] toWhoVkId:userInfo[@"to_who_vk_id"]
                                                                       type:[userInfo[@"type"] integerValue]]];

    completionHandler(UIBackgroundFetchResultNewData);
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    
    return YES;
}

@end
