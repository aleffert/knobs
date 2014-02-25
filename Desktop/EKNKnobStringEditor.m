//
//  EKNKnobStringEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 8/6/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobStringEditor.h"

#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"

@interface EKNKnobStringEditor ()

@property (strong, nonatomic) IBOutlet NSTextField* content;
@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

- (IBAction)textFieldChanged:(id)sender;

@end

@implementation EKNKnobStringEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    
    if(!self.content.currentEditor) {
        self.content.stringValue = info.value;
    }
    
    self.fieldName.stringValue = info.displayName;
}

- (IBAction)textFieldChanged:(id)sender {
    self.info.value = self.content.stringValue;
    [self.delegate propertyEditor:self changedKnob:self.info];
}

@end
