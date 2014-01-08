//
//  EKNKnobSliderEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobSliderEditor.h"

#import "EKNEventTrampolineTableView.h"
#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"

@interface EKNKnobSliderEditor () <EKNEventTrampolineKeyHandler>

@property (strong, nonatomic) IBOutlet NSSlider* slider;
@property (strong, nonatomic) IBOutlet NSTextField* fieldName;
@property (strong, nonatomic) IBOutlet NSTextField* currentValue;
@property (strong, nonatomic) IBOutlet NSTextField* minValue;
@property (strong, nonatomic) IBOutlet NSTextField* maxValue;

@end

@implementation EKNKnobSliderEditor

@synthesize info = _info;
@synthesize delegate = _delegate;

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    self.slider.minValue = [[info.propertyDescription.parameters objectForKey:@(EKNPropertySliderMin)] floatValue];
    self.slider.maxValue = [[info.propertyDescription.parameters objectForKey:@(EKNPropertySliderMax)] floatValue];
    self.slider.continuous = [[info.propertyDescription.parameters objectForKey:@(EKNPropertySliderContinuous)] boolValue];
    self.slider.floatValue = [info.value floatValue];
    self.minValue.floatValue = self.slider.minValue;
    self.maxValue.floatValue = self.slider.maxValue;
    self.fieldName.stringValue = info.label;
    self.currentValue.stringValue = [NSString stringWithFormat:@"%.2f", self.slider.floatValue];
}

- (IBAction)changedSlider:(id)sender {
    self.info.value = @(self.slider.floatValue);
    [self.delegate propertyEditor:self changedKnob:self.info];
    self.currentValue.stringValue = [NSString stringWithFormat:@"%.2f", self.slider.floatValue];
}

- (CGFloat)incrementAmount {
    // This is totally made up, but seems reasonable
    if(self.slider.maxValue - self.slider.minValue <= 5) {
        return .1;
    }
    else {
        return 1;
    }
}

- (void)offsetValueByAmount:(CGFloat)amount {
    CGFloat finalValue = MIN(self.slider.maxValue, MAX(self.slider.minValue, self.slider.floatValue + amount));
    self.slider.floatValue = finalValue;
    [self changedSlider:nil];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString* character = [theEvent charactersIgnoringModifiers];
    unichar code = [character characterAtIndex:0];
    switch (code) {
        case NSDownArrowFunctionKey:
        case NSLeftArrowFunctionKey:
            [self offsetValueByAmount:-1 * [self incrementAmount]];
            break;
        case NSUpArrowFunctionKey:
        case NSRightArrowFunctionKey:
            [self offsetValueByAmount:[self incrementAmount]];
        default:
            break;
    }
}

@end
