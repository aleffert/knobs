//
//  EKNDeviceFinderView.m
//  Knobs
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNDeviceFinderView.h"

#import "EKNDevice.h"
#import "EKNDeviceFinder.h"

@interface EKNDeviceFinderView ()

@property (strong, nonatomic) NSTableView* deviceTable;
@property (strong, nonatomic) EKNDeviceFinder* deviceFinder;

@property (strong, nonatomic) IBOutlet NSButton* chooseButton;

- (IBAction)choseDevice:(id)sender;
- (IBAction)cancel:(id)sender;

@end

static NSString* EKNDeviceNameColumnIdentifier = @"EKNDeviceNameColumnIdentifier";

@implementation EKNDeviceFinderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.deviceTable = [[NSTableView alloc] initWithFrame:self.bounds];
        self.deviceTable.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        self.deviceTable.delegate = self;
        self.deviceTable.dataSource = self;
        self.deviceTable.headerView = nil;
        self.deviceTable.allowsEmptySelection = NO;
        self.deviceTable.allowsMultipleSelection = NO;
        NSTableColumn* column = [[NSTableColumn alloc] initWithIdentifier:EKNDeviceNameColumnIdentifier];
        [self.deviceTable addTableColumn:column];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceListChanged:) name:EKNActiveDeviceListChangedNotification object:nil];
        
        self.deviceFinder = [[EKNDeviceFinder alloc] init];
        
        [self deviceListChanged:nil];
        
        
        NSScrollView* container = [[NSScrollView alloc] initWithFrame:self.bounds];
        [container setDocumentView:self.deviceTable];
        [self addSubview:container];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [self.deviceFinder start];
    [self deviceListChanged:nil];
}

- (void)deviceListChanged:(NSNotification*)notification {
    [self.deviceTable reloadData];
    [self.chooseButton setEnabled:self.deviceFinder.activeDevices.count > 0];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.deviceFinder.activeDevices.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    EKNDevice* device = self.deviceFinder.activeDevices[row];
    return device.displayName;
}

- (NSCell*)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextFieldCell* cell = [[NSTextFieldCell alloc] init];
    return cell;
}

- (IBAction)choseDevice:(id)sender {
    NSUInteger index = [self.deviceTable selectedRow];
    EKNDevice* device = [self.deviceFinder.activeDevices objectAtIndex:index];
    [self.delegate deviceFinderView:self choseDevice:device];
}

- (IBAction)cancel:(id)sender {
    [self.delegate deviceFinderViewCancelled:self];
}

@end
