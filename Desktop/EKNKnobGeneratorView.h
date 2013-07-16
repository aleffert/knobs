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

// Array of EKNKnobInfo*
- (void)representObject:(id)object withKnobs:(NSArray*)properties;
@property (readonly, nonatomic) id representedObject;

- (void)addKnob:(EKNKnobInfo*)knob;
- (void)updateKnobWithID:(NSString*)knobID toValue:(id)value;
- (void)removeKnobWithID:(NSString*)knobID;
- (void)clear;

@end

@protocol EKNKnobGeneratorViewDelegate <NSObject>

- (void)generatorView:(EKNKnobGeneratorView*)view changedKnob:(EKNKnobInfo*)knob;

@end