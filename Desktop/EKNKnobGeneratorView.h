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

// Array of EKNPropertyInfo*
- (void)representObject:(id)object withProperties:(NSArray*)properties;
@property (readonly, nonatomic) id representedObject;

@end

@protocol EKNKnobGeneratorViewDelegate <NSObject>

- (void)generatorView:(EKNKnobGeneratorView*)view changedProperty:(EKNPropertyDescription*)property toValue:(id <NSCoding>)value;

@end