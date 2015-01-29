//
//  UINavigationItem+MultipleButtonsAddition.m
//  VKLovers
//
//  Created by Vitaly Davydov on 29/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "UINavigationItem+MultipleButtonsAddition.h"

@implementation UINavigationItem (MultipleButtonsAddition)
- (void)setRightBarButtonItemsCollection:(NSArray *)rightBarButtonItemsCollection {
    self.rightBarButtonItems = [rightBarButtonItemsCollection sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:NO]]];
}

- (void)setLeftBarButtonItemsCollection:(NSArray *)leftBarButtonItemsCollection {
    self.leftBarButtonItems = [leftBarButtonItemsCollection sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:NO]]];
}

- (NSArray *)rightBarButtonItemsCollection {
    return self.rightBarButtonItems;
}

- (NSArray *)leftBarButtonItemsCollection {
    return self.leftBarButtonItems;
}

@end
