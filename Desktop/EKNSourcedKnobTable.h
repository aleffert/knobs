//
//  EKNSourcedKnobTable.h
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNKnobInfo;
@protocol EKNSourcedKnobTableDelegate;

@interface EKNSourcedKnobTable : NSView

@property (weak, nonatomic) id <EKNSourcedKnobTableDelegate> delegate;

- (void)addKnob:(EKNKnobInfo*)knob;
- (void)updateKnobWithID:(NSString*)knobID toValue:(id)value;
- (void)removeKnobWithID:(NSString*)knobID;
- (void)clear;

@end


@protocol EKNSourcedKnobTableDelegate <NSObject>

- (void)knobTable:(EKNSourcedKnobTable*)table changedKnob:(EKNKnobInfo*)knob;

@end