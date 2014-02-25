//
//  EKNKnobIntEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 12/28/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobIntEditor.h"

#import "EKNEventTrampolineOutlineView.h"
#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"

@interface EKNKnobIntEditor () <EKNEventTrampolineKeyHandler>

@property (strong, nonatomic) IBOutlet NSTextField* field;
@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

@end

@implementation EKNKnobIntEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    self.field.integerValue = [info.value integerValue];
    self.fieldName.stringValue = info.displayName;
}

- (IBAction)textFieldChanged:(id)sender {
    [self valueChangedToInt:self.field.integerValue];
}

- (void)valueChangedToInt:(NSInteger)value {
    self.info.value = [NSNumber numberWithInteger:value];
    [self.delegate propertyEditor:self changedKnob:self.info];
}

- (void)incrementByAmount:(NSInteger)amount {
    NSInteger value = self.field.integerValue + amount;
    self.field.integerValue = value;
    [self valueChangedToInt:value];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString* character = [theEvent charactersIgnoringModifiers];
    unichar code = [character characterAtIndex:0];
    switch (code) {
        case NSDownArrowFunctionKey:
        case NSLeftArrowFunctionKey:
            [self incrementByAmount:-1];
            break;
        case NSUpArrowFunctionKey:
        case NSRightArrowFunctionKey:
            [self incrementByAmount:1];
            break;
        default:
            break;
    }
}

- (IBAction)stepperPressed:(NSStepper*)stepper {
    [self incrementByAmount:stepper.integerValue];
    stepper.floatValue = 0;
}

@end
