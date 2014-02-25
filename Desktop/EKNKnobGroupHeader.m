//
//  EKNKnobGroupHeader.m
//  Knobs-Desktop
//
//  Created by Akiva Leffert on 2/24/14.
//  Copyright (c) 2014 Akiva Leffert. All rights reserved.
//

#import "EKNKnobGroupHeader.h"

#import "EKNKnobInfo.h"

@interface EKNKnobGroupHeader ()

@property (strong, nonatomic) IBOutlet NSTextField* groupName;

@end

@implementation EKNKnobGroupHeader

@synthesize info = _info;
@synthesize delegate = _delegate;

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    self.groupName.stringValue = info.displayName;
}

@end
