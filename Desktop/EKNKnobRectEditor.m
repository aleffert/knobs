//
//  EKNKnobRectEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobRectEditor.h"

#import "EKNPropertyDescription.h"
#import "EKNPropertyInfo.h"

@interface EKNKnobRectEditor ()

@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

@property (strong, nonatomic) IBOutlet NSTextField* x;
@property (strong, nonatomic) IBOutlet NSTextField* y;
@property (strong, nonatomic) IBOutlet NSTextField* width;
@property (strong, nonatomic) IBOutlet NSTextField* height;

@end

@implementation EKNKnobRectEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (void)setInfo:(EKNPropertyInfo *)info {
    _info = info;
    NSRect rect = [info.value rectValue];
    if(!self.x.currentEditor) {
        self.x.floatValue = rect.origin.x;
    }
    if(!self.y.currentEditor) {
        self.y.floatValue = rect.origin.y;
    }
    if(!self.width.currentEditor) {
        self.width.floatValue = rect.size.width;
    }
    if(!self.height.currentEditor) {
        self.height.floatValue = rect.size.height;
    }

    self.fieldName.stringValue = info.propertyDescription.name;
}

- (IBAction)textFieldChanged:(id)sender {
    NSRect rect = NSMakeRect(self.x.floatValue, self.y.floatValue, self.width.floatValue, self.height.floatValue);
    NSValue* value = [NSValue valueWithRect:rect];
    [self.delegate propertyEditor:self changedProperty:self.info.propertyDescription toValue:value];
}

@end
