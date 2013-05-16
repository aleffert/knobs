//
//  EKNViewFrobViewController.m
//  Knobs
//
//  Created by Akiva Leffert on 5/15/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNViewFrobViewController.h"

#import "EKNViewFrob.h"

@interface EKNViewFrobViewController ()

@property (strong, nonatomic) id <EKNConsoleControllerContext> context;
@property (strong, nonatomic) id <EKNChannel> channel;

@end

@implementation EKNViewFrobViewController

- (id)init {
    self = [super initWithNibName:@"EKNViewFrobViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if(self != nil) {
    }
    return self;
}

- (NSString*)title {
    return @"Views";
}

- (void)connectedToDeviceWithContext:(id<EKNConsoleControllerContext>)context onChannel:(id<EKNChannel>)channel {
    self.channel = channel;
    self.context = context;
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSDictionary* message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString* messageType = [message objectForKey:EKNViewFrobSentMessageKey];
    if([messageType isEqualToString:EKNViewFrobMessageBegin]) {
        NSData* responseData = [NSKeyedArchiver archivedDataWithRootObject:@{EKNViewFrobSentMessageKey: EKNViewFrobMessageLoadAll}];
        [self.context sendMessage:responseData onChannel:channel];
    }
    else if([messageType isEqualToString:EKNViewFrobMessageLoadAll]) {
        self.viewInfos = [
        NSLog(@"hierarchy is %@", [message objectForKey:EKNViewFrobLoadAllViewInfosKey]);
    }
}

- (void)disconnectedFromDevice {
}

@end
