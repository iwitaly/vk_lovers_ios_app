//
//  IWConfession.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWConfession.h"

@implementation IWConfession

+ (IWConfession *)confessionWithWhoVkId:(NSString *)whoVkId toWhoVkId:(NSString *)toWhoVkId type:(ConfessionType)type {
    IWConfession *confession = [[IWConfession alloc] init];
    confession.who_vk_id = whoVkId;
    confession.to_who_vk_id = toWhoVkId;
    confession.type = type;
    
    return confession;
}

@end
