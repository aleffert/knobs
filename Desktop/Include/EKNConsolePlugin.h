//
//  EKNConsolePlugin.h
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNChannel.h"
#import "EKNConsolePlugin.h"

@protocol EKNConsoleController;
@class EKNKnobEditorManager;
@class EKNSourceManager;

@protocol EKNConsoleControllerContext <NSObject>

@property (readonly, strong, nonatomic) EKNKnobEditorManager* editorManager;
@property (readonly, strong, nonatomic) EKNSourceManager* sourceManager;

- (void)sendMessage:(NSData*)data onChannel:(id <EKNChannel>)channel;
- (void)updatedView:(NSViewController <EKNConsoleController>*)controller ofChannel:(id <EKNChannel>)channel;

@end

@protocol EKNConsoleController <NSObject>

- (void)connectedToDeviceWithContext:(id <EKNConsoleControllerContext>)context onChannel:(id <EKNChannel>)channel;
- (void)receivedMessage:(NSData*)data onChannel:(id <EKNChannel>)channel;
- (void)disconnectedFromDevice;

@end

@protocol EKNConsolePlugin <NSObject>

/// reverse DNS style unique identifier 
@property (readonly, nonatomic) NSString* name;

- (NSViewController <EKNConsoleController>*)viewControllerWithChannel:(id <EKNChannel>)channel;

@end
