//
//  IWVkManager.h
//  VKLovers
//
//  Created by Vitaly Davydov on 19/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWVkManager : NSObject <VKSdkDelegate>

@property (nonatomic, strong) NSString *currentUserVkId;

//info about current user
+ (VKRequest *)info;
//info about his friends: name, last name, sex, photo 50x50
+ (VKRequest *)allFriends;
+ (instancetype)sharedManager;
- (BOOL)validVKSession;
- (void)login;

@end
