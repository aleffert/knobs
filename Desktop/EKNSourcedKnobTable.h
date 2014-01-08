//
//  EKNSourcedKnobTable.h
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNKnobEditorManager;
@class EKNKnobInfo;
@class EKNSourceManager;
@protocol EKNSourcedKnobTableDelegate;

@interface EKNSourcedKnobTable : NSView

- (id)initWithFrame:(NSRect)frameRect editorManager:(EKNKnobEditorManager*)editorManager sourceManager:(EKNSourceManager*)sourceManager;

@property (weak, nonatomic) id <EKNSourcedKnobTableDelegate> delegate;
@property (readonly, nonatomic) BOOL isEmpty;

- (void)addKnob:(EKNKnobInfo*)knob;
- (void)updateKnobWithID:(NSString*)knobID toValue:(id)value;
- (void)removeKnobWithID:(NSString*)knobID;
- (void)clear;

@end


@protocol EKNSourcedKnobTableDelegate <NSObject>

- (void)knobTable:(EKNSourcedKnobTable*)table changedKnob:(EKNKnobInfo*)knob;

@end