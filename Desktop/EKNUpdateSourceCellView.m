//
//  EKNUpdateSourceCellView.m
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNUpdateSourceCellView.h"

#import "EKNKnobInfo.h"
#import "EKNPropertyDescription.h"

@interface EKNUpdateSourceCellView ()

@property (strong, nonatomic) IBOutlet NSTextField* pathLabel;
@property (strong, nonatomic) IBOutlet NSButton* openButton;
@property (strong, nonatomic) IBOutlet NSButton* saveButton;

@end

@implementation EKNUpdateSourceCellView

- (void)setInfo:(EKNKnobInfo *)info {
    _info = info;
    BOOL hasPath = self.info.sourcePath.length > 0;
    self.pathLabel.stringValue = hasPath ? self.info.sourcePath.lastPathComponent : @"<Unknown>";
    self.openButton.enabled = hasPath;
    self.saveButton.enabled = hasPath && info.propertyDescription.supportsSourceUpdate;
}

- (IBAction)open:(id)sender {
    NSURL* url = [NSURL fileURLWithPath:self.info.sourcePath];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)save:(id)sender {
    [self.delegate updateSourceCell:self shouldSaveKnob:self.info];
}

@end
