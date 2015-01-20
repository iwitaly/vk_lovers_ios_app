//
//  IWUser.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWUser.h"

@implementation IWUser

+ (IWUser *)userWithVkId:(NSString *)vkId mobile:(NSString *)mobile email:(NSString *)email {
    IWUser *user = [[IWUser alloc] init];
    user.vk_id = vkId;
    user.mobile = mobile;
    user.email = email;
    
    return user;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@, %@", self.vk_id, self.mobile, self.email];
}

@end
