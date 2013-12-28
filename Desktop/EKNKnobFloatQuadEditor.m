//
//  EKNKnobFloatQuadEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobFloatQuadEditor.h"

#import "EKNKnobInfo.h"
#import "EKNEventTrampolineTableView.h"
#import "EKNPropertyDescription.h"

@interface EKNKnobFloatQuadEditor () <EKNEventTrampolineKeyHandler>

@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

@property (strong, nonatomic) IBOutlet NSTextField* field1;
@property (strong, nonatomic) IBOutlet NSTextField* field2;
@property (strong, nonatomic) IBOutlet NSTextField* field3;
@property (strong, nonatomic) IBOutlet NSTextField* field4;

@property (strong, nonatomic) IBOutlet NSTextField* name1;
@property (strong, nonatomic) IBOutlet NSTextField* name2;
@property (strong, nonatomic) IBOutlet NSTextField* name3;
@property (strong, nonatomic) IBOutlet NSTextField* name4;

@end

@implementation EKNKnobFloatQuadEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (NSArray*)fields {
    return @[self.field1, self.field2, self.field3, self.field4];
}

- (NSArray*)namesLabels {
    return @[self.name1, self.name2, self.name3, self.name4];
}

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    
    // A rect *should* have the same structure as any other float quad
    NSRect rect = [info.value rectValue];
    CGFloat* rectFields = (CGFloat*)&rect;
    
    [self.fields enumerateObjectsUsingBlock:^(NSTextField* field, NSUInteger idx, BOOL *stop) {
        if(field.currentEditor == nil) {
            field.floatValue = rectFields[idx];
        }
    }];
    
    NSArray* names = self.info.propertyDescription.parameters[@(EKNPropertyFloatQuadFieldNames)];
    [self.namesLabels enumerateObjectsUsingBlock:^(NSTextField* field, NSUInteger idx, BOOL *stop) {
        if(field.currentEditor == nil) {
            field.stringValue = names[idx];
        }
    }];
    
    self.fieldName.stringValue = self.info.label;
}

- (IBAction)textFieldChanged:(id)sender {
    NSRect rect;
    CGFloat* rectFields = (CGFloat*)&rect;
    [self.fields enumerateObjectsUsingBlock:^(NSTextField* field, NSUInteger idx, BOOL *stop) {
        rectFields[idx] = field.floatValue;
    }];
    
    self.info.value = [NSValue valueWithRect:rect];
    [self.delegate propertyEditor:self changedKnob:self.info];
}

- (void)incrementFieldAtIndex:(NSUInteger)index by:(CGFloat)amount {
    NSRect rect;
    CGFloat* rectFields = (CGFloat*)&rect;
    [self.fields enumerateObjectsUsingBlock:^(NSTextField* field, NSUInteger idx, BOOL *stop) {
        CGFloat value = field.floatValue;
        if(idx == index) {
            value += amount;
            field.floatValue = value;
        }
        rectFields[idx] = value;
    }];
    
    self.info.value = [NSValue valueWithRect:rect];
    [self.delegate propertyEditor:self changedKnob:self.info];
}

- (void)handleKeyEventForRect:(NSEvent*)theEvent {
    NSString* character = [theEvent charactersIgnoringModifiers];
    unichar code = [character characterAtIndex:0];
    
    if(theEvent.modifierFlags & NSAlternateKeyMask) {
        switch (code) {
            case NSLeftArrowFunctionKey:
                [self incrementFieldAtIndex:2 by:-1];
                break;
            case NSDownArrowFunctionKey:
                [self incrementFieldAtIndex:3 by:1];
                break;
            case NSRightArrowFunctionKey:
                [self incrementFieldAtIndex:2 by:1];
                break;
            case NSUpArrowFunctionKey:
                [self incrementFieldAtIndex:3 by:-1];
                break;
            default:
                break;
        }
    }
    else {
        switch (code) {
            case NSLeftArrowFunctionKey:
                [self incrementFieldAtIndex:0 by:-1];
                break;
            case NSDownArrowFunctionKey:
                [self incrementFieldAtIndex:1 by:1];
                break;
            case NSRightArrowFunctionKey:
                [self incrementFieldAtIndex:0 by:1];
                break;
            case NSUpArrowFunctionKey:
                [self incrementFieldAtIndex:1 by:-1];
                break;
            default:
                break;
        }
    }
}

- (void)handleKeyEventForEdgeInsets:(NSEvent*)theEvent {
    NSString* character = [theEvent charactersIgnoringModifiers];
    unichar code = [character characterAtIndex:0];
    CGFloat delta = (theEvent.modifierFlags & NSAlternateKeyMask) ? -1 : 1;
    switch (code) {
        case NSLeftArrowFunctionKey:
            [self incrementFieldAtIndex:1 by:delta];
            break;
        case NSDownArrowFunctionKey:
            [self incrementFieldAtIndex:2 by:delta];
            break;
        case NSRightArrowFunctionKey:
            [self incrementFieldAtIndex:3 by:delta];
            break;
        case NSUpArrowFunctionKey:
            [self incrementFieldAtIndex:0 by:delta];
            break;
        default:
            break;
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    NSInteger keyOrder = [self.info.propertyDescription.parameters[@(EKNPropertyFloatQuadKeyOrder)] integerValue];
    switch(keyOrder) {
        case EKNFloatQuadKeyOrderEdgeInsets:
            [self handleKeyEventForEdgeInsets:theEvent];
            break;
        case EKNFloatQuadKeyOrderRect:
            [self handleKeyEventForRect:theEvent];
            break;
    }
}

- (IBAction)stepperPressed:(NSStepper*)stepper {
    [self incrementFieldAtIndex:stepper.tag by:stepper.floatValue];
    stepper.floatValue = 0;
}

@end
