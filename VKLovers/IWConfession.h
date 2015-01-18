//
//  IWConfession.h
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ConfessionType) {
    ConfessionTypeDate,
    ConfessionTypeSex
};

@interface IWConfession : NSObject

@property (nonatomic, strong) NSString *who_vk_id;
@property (nonatomic, strong) NSString *to_who_vk_id;
@property ConfessionType type;


@end
