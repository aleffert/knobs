//
//  EKNKnobFloatPairEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobFloatPairEditor.h"

#import "EKNPropertyDescription.h"
#import "EKNPropertyInfo.h"

@interface EKNKnobFloatPairEditor ()

@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

@property (strong, nonatomic) IBOutlet NSTextField* left;
@property (strong, nonatomic) IBOutlet NSTextField* right;

@property (strong, nonatomic) IBOutlet NSTextField* leftName;
@property (strong, nonatomic) IBOutlet NSTextField* rightName;

@end

@implementation EKNKnobFloatPairEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (void)setInfo:(EKNPropertyInfo *)info {
    _info = info;
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
    
    self.fieldName.stringValue = info.propertyDescription.name;
}

- (IBAction)textFieldChanged:(id)sender {
    NSPoint point = NSMakePoint(self.left.floatValue, self.right.floatValue);
    NSValue* value = [NSValue valueWithPoint:point];
    [self.delegate propertyEditor:self changedProperty:self.info.propertyDescription toValue:value];
}

@end
