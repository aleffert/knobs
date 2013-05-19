//
//  EKNLoggerPlugin.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLoggerPlugin.h"

#import "EKNDevicePluginContext.h"
#import "EKNWireColor.h"
#import "EKNWireImage.h"


@interface EKNLoggerPluginArchiveSubstituter : NSObject <NSKeyedArchiverDelegate>

@end


@interface EKNLoggerPlugin ()

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) NSMutableDictionary* channels;
@property (strong, nonatomic) EKNLoggerPluginArchiveSubstituter* archiveDelegate;

@end


@implementation EKNLoggerPluginArchiveSubstituter

- (id)archiver:(NSKeyedArchiver *)archiver willEncodeObject:(id)object {
    // TODO: Make this a table lookup for easier extensions?
    if([object isKindOfClass:[UIImage class]]) {
        return [[EKNWireImage alloc] initWithImage:object];
    }
    else if([object isKindOfClass:[UIColor class]]) {
        return [[EKNWireColor alloc] initWithColor:object];
    }
    return object;
}

@end

@implementation EKNLoggerPlugin

+ (EKNLoggerPlugin*)sharedPlugin {
    static dispatch_once_t onceToken;
    static EKNLoggerPlugin* logger = nil;
    dispatch_once(&onceToken, ^{
        logger = [[EKNLoggerPlugin alloc] init];
    });
    return logger;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.archiveDelegate = [[EKNLoggerPluginArchiveSubstituter alloc] init];
    }
    return self;
}

- (NSString*)name {
    return @"com.knobs.logger";
}

- (void)beganConnection {
}

- (void)endedConnection {
}

- (void)useContext:(id<EKNDevicePluginContext>)context {
    self.context = context;
}

- (void)receivedMessage:(NSData *)data onChannel:(id<EKNChannel>)channel {
    NSLog(@"Unexpectedly received message");
}

- (id <EKNChannel>)channelWithName:(NSString*)name {
    id <EKNChannel> channel = [self.channels objectForKey:name];
    if(channel == nil && self.context != nil) {
        channel = [self.context channelWithName:name fromPlugin:self];
        [self.channels setObject:channel forKey:name];
    }
    
    return channel;
}

- (void)logToChannel:(NSString *)channelName withRows:(NSArray *)params {
    id <EKNChannel> channel = [self channelWithName:channelName];
    if(self.context.connected && channel != nil) {
        NSMutableData* result = [[NSMutableData alloc] init];
        NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:result];
        archiver.delegate = self.archiveDelegate;
        [archiver encodeObject:params forKey:@"root"];
        [archiver finishEncoding];
        [self.context sendMessage:result onChannel:channel];
    }
}

- (void)logToChannel:(NSString*)channelName withImage:(UIImage*)image {
    [self logToChannel:channelName withRows:@[image]];
}

- (void)logToChannel:(NSString*)channelName withColor:(UIColor*)color {
    [self logToChannel:channelName withRows:@[color]];
}

@end
