//
//  EKNKnobGeneratorView.h
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EKNPropertyDescription;

@protocol EKNKnobGeneratorViewDelegate;

@interface EKNKnobGeneratorView : NSView

- (void)setProperties:(NSArray*)properties;
@property (assign, nonatomic) id <EKNKnobGeneratorViewDelegate> delegate;
@property (strong, nonatomic) id representedObject;

@end

@protocol EKNKnobGeneratorViewDelegate <NSObject>

- (void)generatorView:(EKNKnobGeneratorView*)view updatedProperty:(EKNPropertyDescription*)property toValue:(id <NSCoding>)value;

@end