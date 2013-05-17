//
//  EKNKnobColorEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobColorEditor.h"

#import "EKNPropertyDescription.h"
#import "EKNPropertyInfo.h"
#import "EKNWireColor.h"

@interface EKNKnobColorEditor ()

@property (strong, nonatomic) IBOutlet NSColorWell* colorWell;
@property (strong, nonatomic) IBOutlet NSTextField* fieldName;
@property (strong, nonatomic) IBOutlet NSColor* lastReadColor;

@end

@implementation EKNKnobColorEditor

@synthesize info = _info;
@synthesize delegate = _delegate;

- (void)setInfo:(EKNPropertyInfo *)info {
    _info = info;
    self.fieldName.stringValue = info.propertyDescription.name;
    NSColor* color = info.value;
    if(![self.lastReadColor isEqual:color]) {
        if([color isKindOfClass:[NSNull class]]) {
            self.colorWell.color = [NSColor clearColor];
        }
        else {
            self.colorWell.color = color;
        }
        self.lastReadColor = color;
    }
}

- (IBAction)changedColor:(id)sender {
    [self.delegate propertyEditor:self changedProperty:self.info.propertyDescription toValue:self.colorWell.color];
}

@end
