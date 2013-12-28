//
//  EKNKnobFloatEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 12/28/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobFloatEditor.h"

#import "EKNEventTrampolineTableView.h"
#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"

@interface EKNKnobFloatEditor () <EKNEventTrampolineKeyHandler>

@property (strong, nonatomic) IBOutlet NSTextField* field;
@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

@end

@implementation EKNKnobFloatEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    self.field.floatValue = [info.value floatValue];
    self.fieldName.stringValue = info.propertyDescription.name;
}

- (IBAction)textFieldChanged:(id)sender {
    [self valueChangedToFloat:self.field.floatValue];
}

- (void)valueChangedToFloat:(CGFloat)value {
    self.info.value = [NSNumber numberWithFloat:value];
    [self.delegate propertyEditor:self changedKnob:self.info];
}

- (void)incrementByAmount:(CGFloat)amount {
    CGFloat value = self.field.floatValue + amount;
    self.field.floatValue = value;
    [self valueChangedToFloat:value];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString* character = [theEvent charactersIgnoringModifiers];
    unichar code = [character characterAtIndex:0];
    switch (code) {
        case NSUpArrowFunctionKey:
        case NSLeftArrowFunctionKey:
            [self incrementByAmount:-1];
            break;
        case NSDownArrowFunctionKey:
        case NSRightArrowFunctionKey:
            [self incrementByAmount:1];
            break;
        default:
            break;
    }
}

- (IBAction)stepperPressed:(NSStepper*)stepper {
    [self incrementByAmount:stepper.floatValue];
    stepper.floatValue = 0;
}

@end
