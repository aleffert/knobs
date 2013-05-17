//
//  EKNKnobImageEditor.m
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobImageEditor.h"

#import "EKNPropertyDescription.h"
#import "EKNPropertyInfo.h"
#import "EKNWireImage.h"

@interface EKNKnobImageEditor ()

@property (strong, nonatomic) IBOutlet NSImageView* imageView;
@property (strong, nonatomic) IBOutlet NSTextField* fieldName;

@end

@implementation EKNKnobImageEditor

@synthesize delegate = _delegate;
@synthesize info = _info;

- (void)setInfo:(EKNPropertyInfo *)info {
    _info = info;
    EKNWireImage* image = info.value;
    if([image isKindOfClass:[NSNull class]]) {
        [self.imageView setImage:nil];
    }
    else {
        [self.imageView setImage:image.image];
    }
    self.fieldName.stringValue = info.propertyDescription.name;
}

@end
