//
//  EKNKnobFloatPairEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobFloatPairEditor.h"

#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"

#import "EKNEventTrampolineTableView.h"

@interface EKNKnobFloatPairEditor () <EKNEventTrampolineKeyHandler>

@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

@property (strong, nonatomic) IBOutlet NSTextField* left;
@property (strong, nonatomic) IBOutlet NSTextField* right;

@property (strong, nonatomic) IBOutlet NSTextField* leftName;
@property (strong, nonatomic) IBOutlet NSTextField* rightName;

@end

@implementation EKNKnobFloatPairEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    // A point *should* have the same structure as any other float pair
    // This is kind of sketchy. We should probably pass an array
    NSPoint point = [info.value pointValue];
    if(!self.left.currentEditor) {
        self.left.floatValue = point.x;
    }
    if(!self.right.currentEditor) {
        self.right.floatValue = point.y;
    }
    
    NSArray* names = [self.info.propertyDescription.parameters objectForKey:@(EKNPropertyFloatPairFieldNames)];
    
    self.leftName.stringValue = [names objectAtIndex:0];
    self.rightName.stringValue = [names objectAtIndex:1];
    
    self.fieldName.stringValue = info.label;
}

- (void)valueChangedToPoint:(NSPoint)point {
    NSValue* value = [NSValue valueWithPoint:point];
    self.info.value = value;
    [self.delegate propertyEditor:self changedKnob:self.info];
    
    self.left.floatValue = point.x;
    self.right.floatValue = point.y;
}

- (void)incrementXBy:(CGFloat)amount {
    NSPoint point = CGPointMake(self.left.floatValue, self.right.floatValue);
    point.x += amount;
    [self valueChangedToPoint:point];
}

- (void)incrementYBy:(CGFloat)amount {
    NSPoint point = CGPointMake(self.left.floatValue, self.right.floatValue);
    point.y += amount;
    [self valueChangedToPoint:point];
}

- (IBAction)textFieldChanged:(id)sender {
    NSPoint point = NSMakePoint(self.left.floatValue, self.right.floatValue);
    [self valueChangedToPoint:point];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString* character = [theEvent charactersIgnoringModifiers];
    unichar code = [character characterAtIndex:0];
    switch (code) {
        case NSUpArrowFunctionKey:
            [self incrementYBy:-1];
            break;
        case NSDownArrowFunctionKey:
            [self incrementYBy:1];
            break;
        case NSLeftArrowFunctionKey:
            [self incrementXBy:-1];
            break;
        case NSRightArrowFunctionKey:
            [self incrementXBy:1];
            break;
        default:
            break;
    }
}

- (IBAction)steppedX:(NSStepper*)sender {
    [self incrementXBy:sender.floatValue];
    sender.floatValue = 0;
}

- (IBAction)steppedY:(NSStepper*)sender {
    [self incrementYBy:sender.floatValue];
    sender.floatValue = 0;
}

@end
