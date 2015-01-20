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

@interface IWWebApiManager : NSObject

+ (instancetype)sharedManager;

//users/
- (void)postUser:(IWUser *)user;


//users/vk_id/
- (void)deleteUser:(IWUser *)user;


//users/who_vk_id/who_confession/
//gonna make throw notifications
- (NSArray *)getWhoConfessionListForUser:(IWUser *)user;
- (void)postConfession:(IWConfession *)confession;

//users/who_vk_id/who_confession/to_who_vk_id/
- (IWConfession *)getConfessionFromUser:(IWUser *)who toUser:(IWUser *)toWho;
- (void)putConfession:(IWConfession *)confession;
- (void)deleteConfession:(IWConfession *)confession;

@end
