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
    
    return YES;
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}

@end
