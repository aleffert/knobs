//
//  EKNKnobGroupsView.h
//  Knobs
//
//  Created by Akiva Leffert on 12/22/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNKnobInfo;
@protocol EKNKnobsGroupViewDelegate;

@interface EKNKnobGroupsView : NSView

@property (weak, nonatomic) id <EKNKnobsGroupViewDelegate> delegate;

/// groups is an array of EKNNamedGroup whose items are EKNPropertyInfos
- (void)representObject:(id)object withGroups:(NSArray*)groups;
- (void)clear;

@end


@protocol EKNKnobsGroupViewDelegate <NSObject>

- (void)knobGroupsView:(EKNKnobGroupsView*)view changedKnob:(EKNKnobInfo*)knobInfo;

@end