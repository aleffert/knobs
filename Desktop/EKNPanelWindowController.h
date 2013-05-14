//
//  EKNPanelWindowController.h
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EKNDeviceConnection;
@class EKNDeviceFinder;

@interface EKNPanelWindowController : NSWindowController

@property (strong, nonatomic) EKNDeviceFinder* deviceFinder;
@property (strong, nonatomic) EKNDeviceConnection* deviceConnection;

@end
