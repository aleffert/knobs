//
//  EKNKnobColorEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobColorEditor.h"

#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"
#import "EKNWireColor.h"

@interface EKNKnobColorEditor ()

@property (strong, nonatomic) IBOutlet NSColorWell* colorWell;
@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

@end

@implementation EKNKnobColorEditor

@synthesize info = _info;
@synthesize delegate = _delegate;

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    self.fieldName.stringValue = info.propertyDescription.name;
    NSColor* color = info.value;
    if(!self.colorWell.isActive) {
        if([color isKindOfClass:[NSNull class]]) {
            self.colorWell.color = [NSColor clearColor];
        }
        else {
            self.colorWell.color = color;
        }
    }
}

- (IBAction)changedColor:(id)sender {
    self.info.value = self.colorWell.color;
    [self.delegate propertyEditor:self changedKnob:self.info];
}

@end
