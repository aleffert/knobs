//
//  EKNKnobToggleEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobToggleEditor.h"

#import "EKNPropertyDescription.h"
#import "EKNPropertyInfo.h"

@interface EKNKnobToggleEditor ()

@property (strong, nonatomic) IBOutlet NSButton* checkbox;

@end

@implementation EKNKnobToggleEditor

@synthesize info = _info;
@synthesize delegate = _delegate;

- (void)setInfo:(EKNPropertyInfo *)info {
    _info = info;
    [self.checkbox setTitle:info.propertyDescription.name];
    [self.checkbox setState:[info.value boolValue]];
}

- (IBAction)toggledCheckbox:(id)sender {
    [self.delegate propertyEditor:self changedProperty:self.info.propertyDescription toValue:@(self.checkbox.state)];
}

@end
