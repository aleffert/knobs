//
//  EKNEventTrampolineTableView.h
//  Knobs
//
//  Created by Akiva Leffert on 12/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol EKNEventTrampolineKeyHandler <NSObject>

- (void)keyDown:(NSEvent*)theEvent;
- (void)keyUp:(NSEvent*)theEvent;

@end

@interface EKNEventTrampolineTableView : NSTableView

@end
