//
//  EKNKnobEditorManager.h
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKNRootDerivedKnobInfo;
@class EKNKnobInfo;
@class EKNPropertyDescription;

@interface EKNKnobEditorManager : NSObject

/// Factory to make a new knob info.
- (EKNKnobInfo*)knobInfo;
- (NSArray*)generateChildrenOfKnobRecursively:(EKNKnobInfo*)knobInfo;

- (void)registerPropertyTypesInTableView:(NSTableView*)tableView;
- (CGFloat)editorHeightWithDescription:(EKNPropertyDescription*)description;

@end
