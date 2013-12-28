//
//  EKNKnobAffineTransformEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/18/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobAffineTransformEditor.h"

#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"

#import "NSValue+EKNAffineTransform.h"

@interface EKNKnobAffineTransformEditor ()

@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

// Apparently AppKit doesn't support IBOutletCollection :(
@property (strong, nonatomic) IBOutlet NSTextField* fieldA;
@property (strong, nonatomic) IBOutlet NSTextField* fieldB;
@property (strong, nonatomic) IBOutlet NSTextField* fieldC;
@property (strong, nonatomic) IBOutlet NSTextField* fieldD;
@property (strong, nonatomic) IBOutlet NSTextField* fieldTX;
@property (strong, nonatomic) IBOutlet NSTextField* fieldTY;

@end

@implementation EKNKnobAffineTransformEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (NSArray*)fields {
    return @[
             self.fieldA,
             self.fieldB,
             self.fieldC,
             self.fieldD,
             self.fieldTX,
             self.fieldTY,
             ];
}

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    
    CGAffineTransform transform = [info.value ekn_CGAffineTransformValue];
    // Is this a struct padding disaster?
    CGFloat* transformFields = (CGFloat*)&transform;
    [self.fields enumerateObjectsUsingBlock:^(NSTextField* field, NSUInteger idx, BOOL *stop) {
        if(field.currentEditor == nil) {
            field.floatValue = transformFields[idx];
        }
    }];
    self.fieldName.stringValue = self.info.label;
}

- (IBAction)fieldChanged:(id)sender {
    CGAffineTransform transform;
    CGFloat* transformFields = (CGFloat*)&transform;
    [self.fields enumerateObjectsUsingBlock:^(NSTextField* field, NSUInteger idx, BOOL *stop) {
        transformFields[idx] = field.floatValue;
    }];
    
    self.info.value = [NSValue ekn_valueWithCGAffineTransform:transform];
    [self.delegate propertyEditor:self changedKnob:self.info];
}

@end
