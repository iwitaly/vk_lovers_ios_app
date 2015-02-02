//
//  IWButtonsContainerView.m
//  VKLovers
//
//  Created by Vitaly Davydov on 01/02/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWButtonsContainerView.h"

@implementation IWButtonsContainerView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedButton = SelectedButtonNone;
        self.dateButton.highlighted = NO;
        self.sexButton.highlighted = NO;
    }
    return self;
}
- (void)setSelectedButton:(NSInteger)selectedButton {
    switch (selectedButton) {
        case SelectedButtonNone:
            self.dateButton.selected = self.sexButton.selected = NO;
            _selectedButton = selectedButton;
            break;
        case SelectedButtonDate:
            if (_selectedButton == SelectedButtonDate) {
                self.dateButton.selected = NO;
                _selectedButton = SelectedButtonNone;
            } else {
                self.dateButton.selected = YES;
                self.sexButton.selected = NO;
                _selectedButton = selectedButton;
            }
            break;
        case SelectedButtonSex:
            if (_selectedButton == SelectedButtonSex) {
                self.sexButton.selected = NO;
                _selectedButton = SelectedButtonNone;
            } else {
                self.dateButton.selected = NO;
                self.sexButton.selected = YES;
                _selectedButton = selectedButton;
            }
            break;
    }
}

@end
