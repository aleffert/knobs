//
//  EKNKnobToggleEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobToggleEditor.h"

#import "EKNPropertyDescription.h"
#import "EKNKnobInfo.h"

@interface EKNKnobToggleEditor ()

@property (strong, nonatomic) IBOutlet NSButton* checkbox;
@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

@end

@implementation EKNKnobToggleEditor

@synthesize info = _info;
@synthesize delegate = _delegate;

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    self.fieldName.stringValue = info.propertyDescription.name;
    [self.checkbox setState:[info.value boolValue]];
}

- (IBAction)toggledCheckbox:(id)sender {
    self.info.value = @(self.checkbox.state);
    [self.delegate propertyEditor:self changedKnob:self.info];
}

@end
