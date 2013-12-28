//
//  EKNKnobGeneratorView.h
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "EKNPropertyEditor.h"

@class EKNPropertyDescription;

@protocol EKNKnobGeneratorViewDelegate;

@interface EKNKnobGeneratorView : NSView <EKNPropertyEditorDelegate>

@property (assign, nonatomic) IBOutlet id <EKNKnobGeneratorViewDelegate> delegate;

/// properties is an array of EKNKnobInfo*
- (void)representObject:(id)object withKnobs:(NSArray*)properties;

@end

@protocol EKNKnobGeneratorViewDelegate <NSObject>

- (void)generatorView:(EKNKnobGeneratorView*)view changedKnob:(EKNKnobInfo*)knob;

@end