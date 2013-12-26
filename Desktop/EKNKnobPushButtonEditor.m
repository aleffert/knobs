//
//  EKNKnobPushButtonEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 12/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobPushButtonEditor.h"

#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"

@interface EKNKnobPushButtonEditor ()

@property (strong, nonatomic) IBOutlet NSButton* button;

@end

@implementation EKNKnobPushButtonEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    self.button.title = info.propertyDescription.name;
}

- (IBAction)action:(id)sender {
    [self.delegate propertyEditor:self changedKnob:self.info];
}

@end
