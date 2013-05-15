//
//  EKNDeviceFinderView.h
//  Knobs
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EKNDevice;
@protocol EKNDeviceFinderViewDelegate;

@interface EKNDeviceFinderView : NSView <NSTableViewDelegate, NSTableViewDataSource>

@property (weak, nonatomic) IBOutlet id <EKNDeviceFinderViewDelegate> delegate;

@end

@protocol EKNDeviceFinderViewDelegate <NSObject>

- (void)deviceFinderView:(EKNDeviceFinderView*)view choseDevice:(EKNDevice*)device;
- (void)deviceFinderViewCancelled:(EKNDeviceFinderView*)view;

@end