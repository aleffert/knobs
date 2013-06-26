//
//  EKNKnobFloatQuadEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobFloatQuadEditor.h"

#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"

@interface EKNKnobFloatQuadEditor ()

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
    self.fieldName.stringValue = self.info.propertyDescription.name;
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

@end
