//
//  EKNConsoleWindowController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNConsoleWindowController.h"

#import "EKNConsoleControllerContextDispatcher.h"
#import "EKNConsolePlugin.h"
#import "EKNConsolePluginRegistry.h"
#import "EKNDevice.h"
#import "EKNDeviceConnection.h"
#import "EKNDeviceFinder.h"
#import "EKNDeviceFinderView.h"
#import "EKNNamedChannel.h"

@interface EKNConsoleWindowController () <EKNDeviceFinderViewDelegate, EKNDeviceConnectionDelegate, EKNConsoleControllerContext>

@property (strong, nonatomic) EKNDevice* activeDevice;
@property (assign, nonatomic) BOOL showingDeviceFinder;
@property (strong, nonatomic) EKNDeviceFinder* deviceFinder;
@property (strong, nonatomic) EKNDeviceConnection* deviceConnection;

@property (strong, nonatomic) EKNConsolePluginRegistry* pluginRegistry;
@property (strong, nonatomic) EKNConsoleControllerContextDispatcher* pluginContext;

@property (strong, nonatomic) IBOutlet NSPanel* devicePickerSheet;
@property (strong, nonatomic) IBOutlet EKNDeviceFinderView* finderView;
@property (strong, nonatomic) IBOutlet NSTabView* tabs;

@property (strong, nonatomic) NSMutableDictionary* activeChannels;

@end

@implementation EKNConsoleWindowController

- (id)initWithPluginRegistry:(EKNConsolePluginRegistry*)pluginRegistry {
    self = [super init];
    if(self != nil) {
        self.pluginRegistry = pluginRegistry;
        self.pluginContext = [[EKNConsoleControllerContextDispatcher alloc] init];
        self.pluginContext.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString*)windowNibName {
    return @"EKNConsoleWindowController";
}

- (void)windowDidLoad
{
    self.activeChannels = [[NSMutableDictionary alloc] init];
    [super windowDidLoad];
    self.window.delegate = self;
    [self showDevicePicker];
}

- (void)windowWillClose:(NSNotification *)notification {
    [self.deviceConnection close];
    [self.delegate willCloseWindowWithController:self];
}

- (void)showDevicePicker {
    NSAssert([NSThread isMainThread], @"Not on main thread");
    self.showingDeviceFinder = YES;
    [[NSBundle mainBundle] loadNibNamed:@"EKNDeviceFinderSheet" owner:self topLevelObjects:nil];
    [NSApp beginSheet:self.devicePickerSheet modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (void)deviceFinderViewCancelled:(EKNDeviceFinderView *)view {
    [NSApp endSheet:self.devicePickerSheet];
    [self.window orderOut:nil];
    [self.delegate willCloseWindowWithController:self];
}

- (void)deviceFinderView:(EKNDeviceFinderView *)view choseDevice:(EKNDevice *)device {
    self.deviceConnection = [[EKNDeviceConnection alloc] init];
    self.deviceConnection.delegate = self;
    [self.deviceConnection connectToDevice:device];
    [NSApp endSheet:self.devicePickerSheet];
    [self.devicePickerSheet orderOut:nil];
}

- (void)addController:(NSViewController<EKNConsoleController>*)controller onChannel:(EKNNamedChannel*)channel {
    [self.activeChannels setObject:controller forKey:channel];
    NSTabViewItem* item = [[NSTabViewItem alloc] initWithIdentifier:channel];
    [item setLabel:controller.title];
    [item setView:controller.view];
    [self.tabs addTabViewItem:item];
}

- (void)deviceConnection:(EKNDeviceConnection *)connection receivedMessage:(NSData *)data onChannel:(EKNNamedChannel *)channel {
    NSViewController<EKNConsoleController>* controller = [self.activeChannels objectForKey:channel];
    if(controller == nil) {
        id <EKNConsolePlugin> plugin = [self.pluginRegistry pluginWithName:channel.ownerName];
        controller = [plugin viewControllerWithChannel:channel];
        [controller connectedToDeviceWithContext:self.pluginContext onChannel:channel];
        [self addController:controller onChannel:channel];
    }
    [controller receivedMessage:data onChannel:channel];
}

- (void)deviceConnectionClosed:(EKNDeviceConnection *)connection {
    for(id <EKNChannel> channel in self.activeChannels.allKeys) {
        NSViewController<EKNConsoleController>* controller = [self.activeChannels objectForKey:channel];
        [controller disconnectedFromDevice];
    }
}

- (void)sendMessage:(NSData *)data onChannel:(EKNNamedChannel*)channel {
    [self.deviceConnection sendMessage:data onChannel:channel];
}

- (void)updatedView:(NSViewController<EKNConsoleController> *)controller ofChannel:(id<EKNChannel>)channel {
    // TODO. Mark tab as unread
}

- (IBAction)close:(id)sender {
    [self close];
}

@end
