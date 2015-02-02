//
//  IWButtonsContainerView.h
//  VKLovers
//
//  Created by Vitaly Davydov on 01/02/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SelectedButton) {
    SelectedButtonNone = -1,
    SelectedButtonDate = 0,
    SelectedButtonSex = 1
};

@interface IWButtonsContainerView : UIView

@property (nonatomic, weak) IBOutlet UIButton *dateButton;
@property (nonatomic, weak) IBOutlet UIButton *sexButton;
@property (nonatomic) NSInteger selectedButton; //-1, 0 ,1

@end
