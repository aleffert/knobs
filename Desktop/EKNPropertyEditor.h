//
//  EKNPropertyEditor.h
//  Knobs
//
//  Created by Akiva Leffert on 5/17/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNKnobInfo;

@protocol EKNPropertyEditor;

@protocol EKNPropertyEditorDelegate <NSObject>

- (void)propertyEditor:(id <EKNPropertyEditor>)editor changedKnob:(EKNKnobInfo*)knob;

@end

@protocol EKNPropertyEditor <NSObject>

@property (weak, nonatomic) IBOutlet id <EKNPropertyEditorDelegate> delegate;
@property (strong, nonatomic) EKNKnobInfo* info;

@end
