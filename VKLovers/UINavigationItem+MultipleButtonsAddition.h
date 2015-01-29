//
//  UINavigationItem+MultipleButtonsAddition.h
//  VKLovers
//
//  Created by Vitaly Davydov on 29/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (MultipleButtonsAddition)
@property (nonatomic, strong) IBOutletCollection(UIBarButtonItem) NSArray* rightBarButtonItemsCollection;
@property (nonatomic, strong) IBOutletCollection(UIBarButtonItem) NSArray* leftBarButtonItemsCollection;
@end
