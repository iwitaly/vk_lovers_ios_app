//
//  Friend.h
//  VKLovers
//
//  Created by Vitaly Davydov on 19/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * avatar;
@property (nonatomic, retain) NSNumber * choice;

@end
