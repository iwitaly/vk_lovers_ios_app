//
//  IWSegmentControl.m
//  VKLovers
//
//  Created by Vitaly Davydov on 20/01/15.
//  Copyright (c) 2015 Vitaly Davydov. All rights reserved.
//

#import "IWSegmentControl.h"

@implementation IWSegmentControl

- (void)awakeFromNib {
//    self.tintColor = [UIColor blackColor];
}

+ (BOOL)isIOS7 {
    static BOOL isIOS7 = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSInteger deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
        if (deviceSystemMajorVersion >= 7) {
            isIOS7 = YES;
        }
        else {
            isIOS7 = NO;
        }
    });
    return isIOS7;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSInteger previousSelectedSegmentIndex = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
    if (![[self class] isIOS7]) {
        // before iOS7 the segment is selected in touchesBegan
        if (previousSelectedSegmentIndex == self.selectedSegmentIndex) {
            // if the selectedSegmentIndex before the selection process is equal to the selectedSegmentIndex
            // after the selection process the superclass won't send a UIControlEventValueChanged event.
            // So we have to do this ourselves.
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    CGPoint viewPoint = [self convertPoint:locationPoint fromView:self];
    if ([self pointInside:viewPoint withEvent:event]) {
        int oldValue = self.selectedSegmentIndex;
        [super touchesEnded:touches withEvent:event];
        if (oldValue == self.selectedSegmentIndex)
        {
            [super setSelectedSegmentIndex:UISegmentedControlNoSegment];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}


@end
