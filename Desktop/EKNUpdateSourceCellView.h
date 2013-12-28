//
//  EKNUpdateSourceCellView.h
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EKNKnobInfo;
@protocol EKNUpdateSourceCellViewDelegate;

@interface EKNUpdateSourceCellView : NSView

@property (weak, nonatomic) id <EKNUpdateSourceCellViewDelegate> delegate;
@property (strong, nonatomic) EKNKnobInfo* info;

@end

@protocol EKNUpdateSourceCellViewDelegate <NSObject>

- (void)updateSourceCell:(EKNUpdateSourceCellView*)cell shouldSaveKnob:(EKNKnobInfo*)info;

@end