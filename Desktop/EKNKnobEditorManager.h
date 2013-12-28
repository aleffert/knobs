//
//  EKNKnobEditorManager.h
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNPropertyDescription.h"

@interface EKNKnobEditorManager : NSObject

+ (EKNKnobEditorManager*)sharedManager;

- (void)registerPropertyTypesInTableView:(NSTableView*)tableView;
- (CGFloat)editorHeightOfType:(EKNPropertyType)type;

@end
