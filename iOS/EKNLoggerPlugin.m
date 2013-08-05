//
//  EKNLoggerPlugin.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNLoggerPlugin.h"

#import "EKNDevicePluginContext.h"

#import "NSData+Base64.h"

@implementation NSObject (EKNLogger)

- (NSString*)ekn_html {
    NSMutableString* string = self.description.mutableCopy;
    CFStringTransform((__bridge CFMutableStringRef)string, NULL, CFSTR("Any-Hex/XML"), NO);
    return string;
}

@end

@implementation UIColor (EKNLogger)

- (NSString*)ekn_html {
    // TODO Deal with pattern colors
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    // TODO Treat opacity in a less stupid way. e.g. the triangles in the color picker or an underlying grid pattern
    return [NSString stringWithFormat:@"<span style=\"width:40pt; height:40pt; background-color:rgb(%d, %d, %d) opacity:%f;\"></span>",(int)round(255 * r), (int)round(255 * g),  (int)round(255 * b), a];
}

@end

@implementation UIImage (EKNLogger)

- (NSString*)ekn_html {
    NSData* data = UIImagePNGRepresentation(self);
    NSString* encodedImageData = [data ekn_base64EncodedString];
    return [NSString stringWithFormat:@"<img src=\"data:image/png;base64,%@\"/>", encodedImageData];
}

@end

@interface EKNLoggerPlugin ()

@property (strong, nonatomic) id <EKNDevicePluginContext> context;
@property (strong, nonatomic) NSMutableDictionary* channels;

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
        self.defaultChannelName = @"Log";
    }
    return self;
}

- (NSString*)name {
    return @"com.knobs.logger";
}

- (void)beganConnection {
    [self logToChannel:nil withHTMLString:@"Connected"];
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

- (void)logToChannel:(NSString *)channelName withHTMLString:(NSString *)string {
    if(channelName == nil) {
        channelName = self.defaultChannelName;
    }
    id <EKNChannel> channel = [self channelWithName:channelName];
    if(self.context.connected && channel != nil) {
        NSString* fullString = [NSString stringWithFormat:@"<b>%@:</b> %@", [[NSDate date] descriptionWithLocale:nil], string];
        NSData* archive = [NSKeyedArchiver archivedDataWithRootObject:fullString];
        [self.context sendMessage:archive onChannel:channel];
    }
}

- (void)logToChannel:(NSString *)channelName withString:(NSString *)string {
    [self logToChannel:channelName withHTMLString:string.ekn_html];
}

- (void)logToChannel:(NSString*)channelName withImage:(UIImage*)image {
    [self logToChannel:channelName withHTMLString:image.ekn_html];
}

- (void)logToChannel:(NSString*)channelName withColor:(UIColor*)color {
    [self logToChannel:channelName withHTMLString:color.ekn_html];
}

@end



void EKNLogChannel(NSString* channel, NSString* formatHTML, ...) {
    va_list args;
    va_start(args, formatHTML);
    NSString* message = [[NSString alloc] initWithFormat:formatHTML arguments:args];
    [[EKNLoggerPlugin sharedPlugin] logToChannel:channel withHTMLString:message];
}
void EKNLogChannelImage(NSString* channel, UIImage* image) {
    [[EKNLoggerPlugin sharedPlugin] logToChannel:channel withImage:image];
}
void EKNLogChannelColor(NSString* channel, UIColor* color) {
    [[EKNLoggerPlugin sharedPlugin] logToChannel:(channel) withColor:(color)];
}

// These variants use the defaultChannelName
void EKNLog(NSString* formatHTML, ...) {
    va_list args;
    va_start(args, formatHTML);
    NSString* message = [[NSString alloc] initWithFormat:formatHTML arguments:args];
    [[EKNLoggerPlugin sharedPlugin] logToChannel:nil withHTMLString:message];
}

void EKNLogImage(UIImage* image) {
    EKNLogChannelImage(nil, image);
}
void EKNLogColor(UIColor* color) {
    EKNLogChannelColor(nil, color);
}