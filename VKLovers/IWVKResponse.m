//
//  IWVKResponse.m
//  VKLovers
//
//  Created by Vitaly Davydov on 18/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWVKResponse.h"

@implementation IWVKResponse

- (id)parsedModel {
    id data = [NSJSONSerialization JSONObjectWithData:self.json options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@", data);
    return nil;
}

@end
