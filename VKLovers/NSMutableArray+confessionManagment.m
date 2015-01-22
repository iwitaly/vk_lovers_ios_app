//
//  NSMutableArray+confessionManagment.m
//  VKLovers
//
//  Created by Vitaly Davydov on 22/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "NSMutableArray+confessionManagment.h"

@implementation NSMutableArray (confessionManagment)

- (void)deleteConfessionWithWhoVkId:(NSString *)whoVkId toWhoVkId:(NSString *)toWhoVkId {
    IWConfession *confession = nil;
    for (IWConfession *conf in self) {
        if (([conf.who_vk_id isEqualToString:whoVkId]) && ([conf.to_who_vk_id isEqualToString:toWhoVkId])) {
            confession = conf;
            break;
        }
    }
    
    if (confession) {
        [self removeObject:confession];
    }
}

- (void)changeConfessionTypeWithWhoVkId:(NSString *)whoVkId toWhoVkId:(NSString *)toWhoVkId andType:(ConfessionType)type {
    IWConfession *confession = [IWConfession confessionWithWhoVkId:whoVkId toWhoVkId:toWhoVkId type:type];
    [self deleteConfessionWithWhoVkId:whoVkId toWhoVkId:toWhoVkId];
    [self addObject:confession];
}

@end
