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

@end

@implementation EKNKnobColorEditor

@synthesize info = _info;
@synthesize delegate = _delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)setInfo:(EKNPropertyInfo *)info {
    _info = info;
    self.fieldName.stringValue = info.propertyDescription.name;
    NSColor* color = info.value;
    if([color isKindOfClass:[NSNull class]]) {
        self.colorWell.color = [NSColor clearColor];
    }
    else {
        self.colorWell.color = color;
    }
}

- (IBAction)changedColor:(id)sender {
    [self.delegate propertyEditor:self changedProperty:self.info.propertyDescription toValue:self.colorWell.color];
}

@end
