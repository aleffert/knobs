//
//  EKNKnobEditorManager.h
//  Knobs
//
//  Created by Akiva Leffert on 12/27/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EKNKnobEditorManager : NSObject

+ (EKNKnobEditorManager*)sharedManager;

- (void)registerPropertyTypesInTableView:(NSTableView*)tableView;
- (CGFloat)editorHeightOfType:(NSString*)type;

@end
