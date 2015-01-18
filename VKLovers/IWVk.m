//
//  IWVk.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWVk.h"

@implementation IWVk

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


@end
