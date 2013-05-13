//
//  EKNPanelWindowController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNPanelWindowController.h"

#import "EKNDevice.h"
#import "EKNDeviceFinder.h"

@interface EKNPanelWindowController ()

@property (strong, nonatomic) IBOutlet NSPopUpButton* devicePopup;
@property (strong, nonatomic) EKNDevice* activeDevice;

@end

@implementation EKNPanelWindowController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString*)windowNibName {
    return @"EKNPanelWindowController";
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceListChanged:) name:EKNActiveDeviceListChangedNotification object:nil];
}

- (NSMenu*)menuFromDevices:(NSArray*)devices activeDevice:(EKNDevice*)activeDevice {
    NSMenu* menu = [[NSMenu alloc] init];
    if(devices.count == 0) {
        NSMenuItem* noneItem = [[NSMenuItem alloc] initWithTitle:@"No Devices Found" action:@selector(choseNoDevice:) keyEquivalent:@""];
        [menu addItem:noneItem];
    }
    else {
        NSMenuItem* noneItem = [[NSMenuItem alloc] initWithTitle:@"None" action:@selector(choseNoDevice:) keyEquivalent:@""];
        [menu addItem:noneItem];
        for(EKNDevice* device in devices) {
            NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:device.name action:@selector(choseDevice:) keyEquivalent:@""];
            item.representedObject = device;
            [menu addItem:item];
        }
    }
    
    return menu;
}

- (void)deviceListChanged:(NSNotification*)notification {
    NSLog(@"devices are %@", self.deviceFinder.activeDevices);
    self.devicePopup.menu = [self menuFromDevices:self.deviceFinder.activeDevices activeDevice:self.activeDevice];
    if(self.activeDevice == nil) {
        [self.devicePopup selectItemAtIndex:0];
    }
    else {
        NSUInteger index = [self.devicePopup.menu.itemArray indexOfObjectPassingTest:^BOOL(NSMenuItem* obj, NSUInteger idx, BOOL *stop) {
            return [obj.representedObject isEqualTo:self.activeDevice];
        }];
        if(index == NSNotFound) {
            [self.devicePopup selectItemAtIndex:0];
        }
        else {
            [self.devicePopup selectItemAtIndex:index];
        }
    }
}

- (IBAction)choseNoDevice:(id)sender {
    self.activeDevice = nil;
    NSLog(@"chose device: %@", nil);
}

- (IBAction)choseDevice:(NSMenuItem*)sender {
    NSLog(@"chose device: %@", sender.representedObject);
    self.activeDevice = [sender representedObject];
}

@end
