//
//  IWVk.h
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "VKApi.h"

@interface IWVk : VKApi

//info about current user
+ (VKRequest *)info;
//info about his friends: name, last name, sex, photo 50x50
+ (VKRequest *)allFriends;

@end
