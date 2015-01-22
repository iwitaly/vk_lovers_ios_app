//
//  NSMutableArray+confessionManagment.h
//  VKLovers
//
//  Created by Vitaly Davydov on 22/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWConfession.h"

@interface NSMutableArray (confessionManagment)

- (void)deleteConfessionWithWhoVkId:(NSString *)whoVkId toWhoVkId:(NSString *)toWhoVkId;
- (void)changeConfessionTypeWithWhoVkId:(NSString *)whoVkId toWhoVkId:(NSString *)toWhoVkId andType:(ConfessionType)type;

@end
