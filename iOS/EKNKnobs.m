//
//  EKNKnobs.m
//  Knobs-client
//
//  Created by Akiva Leffert on 5/13/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNKnobs.h"

#import "BLIP.h"
#import "MYBonjourRegistration.h"

#import "EKNSharedConstants.h"

@interface EKNKnobs () <TCPListenerDelegate>

+ (EKNKnobs*)sharedController;

@property (strong, nonatomic) BLIPListener* listener;
@property (strong, nonatomic) MYBonjourRegistration* bonjourBroadcast;

@end

@implementation EKNKnobs

+ (EKNKnobs*)sharedController {
    static dispatch_once_t onceToken;
    static EKNKnobs* controller = nil;
    dispatch_once(&onceToken, ^{
        controller = [[EKNKnobs alloc] init];
    });
    
    return controller;
}

- (id)init {
    if(self = [super init]) {
        self.listener = [[BLIPListener alloc] initWithPort:0];
        self.listener.delegate = self;
        self.bonjourBroadcast = [[MYBonjourRegistration alloc] initWithServiceType:@"_knobs._tcp" port:0];
        self.bonjourBroadcast.name = [NSString stringWithFormat:@"%@ - %@", [[UIDevice currentDevice] name], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    }
    return self;
}

+ (void)start {
    [[self sharedController] start];
}

+ (void)stop {
    [[self sharedController] stop];
}

- (void)start {
    if(!self.listener.isOpen) {
        [self.listener open];
        self.bonjourBroadcast.port = self.listener.port;
        [self.bonjourBroadcast start];
    }
}

- (void)stop {
    if(self.listener.isOpen) {
        [self.bonjourBroadcast stop];
        [self.listener close];
    }
}

- (void)listener:(TCPListener *)listener didAcceptConnection:(TCPConnection *)connection {
    NSLog(@"connection is %@", connection);
}

@end
