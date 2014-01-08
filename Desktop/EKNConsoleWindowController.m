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
#import "EKNKnobEditorManager.h"
#import "EKNSourceManager.h"
#import "EKNNamedChannel.h"

static NSString* const EKNLastUsedDeviceServiceName = @"EKNLastUsedDeviceServiceName";
static NSString* const EKNLastUsedDeviceHostName = @"EKNLastUsedDeviceHostName";

@interface EKNConsoleWindowController () <EKNDeviceConnectionDelegate, EKNConsoleControllerContext>

@property (strong, nonatomic) EKNDevice* activeDevice;
@property (strong, nonatomic) EKNDeviceFinder* deviceFinder;
@property (strong, nonatomic) EKNDeviceConnection* deviceConnection;

@property (strong, nonatomic) EKNConsolePluginRegistry* pluginRegistry;
@property (strong, nonatomic) EKNConsoleControllerContextDispatcher* pluginContext;

@property (strong, nonatomic) IBOutlet NSTabView* tabs;
@property (strong, nonatomic) IBOutlet NSPopUpButton* popup;

@property (strong, nonatomic) NSMutableDictionary* activeChannels;

@property (strong, nonatomic) EKNKnobEditorManager* editorManager;
@property (strong, nonatomic) EKNSourceManager* sourceManager;

@end

@implementation EKNConsoleWindowController

- (id)initWithPluginRegistry:(EKNConsolePluginRegistry*)pluginRegistry {
    self = [super init];
    if(self != nil) {
        self.pluginRegistry = pluginRegistry;
        self.pluginContext = [[EKNConsoleControllerContextDispatcher alloc] init];
        self.pluginContext.delegate = self;
        
        self.deviceFinder = [[EKNDeviceFinder alloc] init];
        self.editorManager = [[EKNKnobEditorManager alloc] init];
        self.sourceManager = [[EKNSourceManager alloc] init];
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
    self.deviceConnection = [[EKNDeviceConnection alloc] init];
    self.deviceConnection.delegate = self;
    
    self.activeChannels = [[NSMutableDictionary alloc] init];
    [super windowDidLoad];
    self.window.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceListChanged) name:EKNActiveDeviceListChangedNotification object:nil];

    [self rebuildPopupWithDevices:@[]];
    
    self.deviceFinder = [[EKNDeviceFinder alloc] init];
    [self.deviceFinder start];
}

- (void)windowWillClose:(NSNotification *)notification {
    [self.deviceConnection close];
}

- (IBAction)close:(id)sender {
    [self close];
}

#pragma mark Device Popup

- (BOOL)isLastSeenDevice:(EKNDevice*)device {
    NSString* lastDeviceName = [[NSUserDefaults standardUserDefaults] objectForKey:EKNLastUsedDeviceServiceName];
    NSString* lastDeviceHost = [[NSUserDefaults standardUserDefaults] objectForKey:EKNLastUsedDeviceHostName];
    
    return [device.serviceName isEqualToString:lastDeviceName] && [device.hostName isEqualToString:lastDeviceHost];
}

- (void)saveLastSeenDevice:(EKNDevice*)device {
    [[NSUserDefaults standardUserDefaults] setObject:device.serviceName forKey:EKNLastUsedDeviceServiceName];
    [[NSUserDefaults standardUserDefaults] setObject:device.hostName forKey:EKNLastUsedDeviceHostName];
}

- (void)rebuildPopupWithDevices:(NSArray*)devices {
    [self.popup.menu removeAllItems];
    
    if(devices.count == 0) {
        [self.popup.menu addItemWithTitle:@"No Devices Found" action:@selector(choseDeviceItem:) keyEquivalent:@""];
    }
    else {
        [self.popup.menu addItemWithTitle:@"None" action:@selector(choseDeviceItem:) keyEquivalent:@""];
    }
    
    for(EKNDevice* device in devices) {
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:device.displayName action:@selector(choseDeviceItem:) keyEquivalent:@""];
        item.representedObject = device;
        item.target = self;
        [self.popup.menu addItem:item];
        if([device isEqualToDevice:self.deviceConnection.activeDevice]) {
            item.state = NSOnState;
            [self.popup selectItem:item];
        }
    }

}

- (void)switchToDevice:(EKNDevice*)device {
    if(![self.deviceConnection.activeDevice isEqualToDevice:device]) {
        [self.deviceConnection connectToDevice:device];
        [self rebuildPopupWithDevices:[self devices]];
    }
}

- (void)choseDeviceItem:(NSMenuItem*)item {
    EKNDevice* device = item.representedObject;
    [self switchToDevice:device];
    [self saveLastSeenDevice:device];
}

#pragma mark Device Finder

- (NSArray*)devices {
    NSArray* devices = self.deviceFinder.activeDevices;
    if(self.deviceConnection.activeDevice != nil && ![devices containsObject:self.deviceConnection.activeDevice]) {
        return [@[self.deviceConnection.activeDevice] arrayByAddingObjectsFromArray:devices];
    }
    else {
        return devices;
    }
}

- (void)deviceListChanged {
    NSArray* devices = [self devices];
    [self rebuildPopupWithDevices:devices];
    
    if(self.deviceConnection.activeDevice == nil) {
        NSUInteger index = [devices indexOfObjectPassingTest:^BOOL(EKNDevice* device, NSUInteger idx, BOOL *stop) {
            return [self isLastSeenDevice:device];
        }];
        if(index != NSNotFound) {
            [self switchToDevice:devices[index]];
        }
    }
}

#pragma mark Device Connection
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
        (void)controller.view;
        [controller connectedToDeviceWithContext:self.pluginContext onChannel:channel];
        [self addController:controller onChannel:channel];
    }
    [controller receivedMessage:data onChannel:channel];
}

- (void)deviceConnectionOpened:(EKNDeviceConnection *)connection {
    for(id <EKNChannel> channel in self.activeChannels.allKeys) {
        NSViewController<EKNConsoleController>* controller = [self.activeChannels objectForKey:channel];
        [controller connectedToDeviceWithContext:self.pluginContext onChannel:channel];
    }
}

- (void)deviceConnectionClosed:(EKNDeviceConnection *)connection {
    for(id <EKNChannel> channel in self.activeChannels.allKeys) {
        NSViewController<EKNConsoleController>* controller = [self.activeChannels objectForKey:channel];
        [controller disconnectedFromDevice];
    }
    [self deviceListChanged];
}

- (void)sendMessage:(NSData *)data onChannel:(EKNNamedChannel*)channel {
    [self.deviceConnection sendMessage:data onChannel:channel];
}

- (void)updatedView:(NSViewController<EKNConsoleController> *)controller ofChannel:(id<EKNChannel>)channel {
    // TODO. Mark tab as unread
}

- (IBAction)nextTab:(id)sender {
    NSInteger index = [self.tabs indexOfTabViewItem:self.tabs.selectedTabViewItem];
    [self.tabs selectTabViewItemAtIndex:(index + 1) % self.tabs.numberOfTabViewItems];
}

- (IBAction)previousTab:(id)sender {
    NSInteger index = [self.tabs indexOfTabViewItem:self.tabs.selectedTabViewItem];
    [self.tabs selectTabViewItemAtIndex:(index - 1 + self.tabs.numberOfTabViewItems) % self.tabs.numberOfTabViewItems];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if(menuItem.action == @selector(nextTab:) || menuItem.action == @selector(previousTab:)) {
        return self.activeChannels.count > 1;
    }
    else {
        return YES;
    }
}

@end
