//
//  IWWebApiManager.h
//  VKLovers_web_API
//
//  Created by Vitaly Davydov on 20/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWUser.h"
#import "IWConfession.h"

#define k_NotificationGotConfessionsFromServer @"kNotificationGotConfessionsFromServer"

typedef void(^IWConfessionHandler)(NSMutableArray *response);

@protocol IWWebApiManagerDelegate <NSObject>

- (void)didEndPostConfession:(IWConfession *)confession withResult:(BOOL)is_completed;

@end

@interface IWWebApiManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, weak) id <IWWebApiManagerDelegate> webManagerDelegate;

//users/
- (void)postUser:(IWUser *)user;


//users/vk_id/
- (void)deleteUser:(IWUser *)user;


//users/who_vk_id/who_confession/
//gonna make throw notifications
- (void)getWhoConfessionListForUser:(IWUser *)user withCompletion:(IWConfessionHandler)handler;
- (void)postConfession:(IWConfession *)confession;
- (void)getWhoConfessionListForCurrentUserWithCompletion:(IWConfessionHandler)handler;

//users/who_vk_id/who_confession/to_who_vk_id/
- (IWConfession *)getConfessionFromUser:(IWUser *)who toUser:(IWUser *)toWho;
- (void)putConfession:(IWConfession *)confession;
- (void)deleteConfession:(IWConfession *)confession;

//users/who_confession/
- (void)postArrayOfConfessions:(NSArray *)confessions;
- (void)removeConfessions:(NSArray *)confessions;

@end
