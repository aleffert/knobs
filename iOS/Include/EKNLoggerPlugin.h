//
//  EKNLoggerPlugin.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 5/14/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EKNDevicePlugin.h"

@interface EKNLoggerPlugin : NSObject <EKNDevicePlugin>

/// This class is not currently thread safe.
/// This seems like a major disadvantage for a logging framework
/// But it does make it easier to send stuff from the debugger console
/// Without having to hit continue before it sends
/// TODO: Fix this to be thread safe, but still send stuff when stopped in the debugger

+ (EKNLoggerPlugin*)sharedPlugin;

- (void)logToChannel:(NSString*)channelName withString:(NSString*)string;
- (void)logToChannel:(NSString*)channelName withHTMLString:(NSString*)string;
- (void)logToChannel:(NSString*)channelName withImage:(UIImage*)image;
- (void)logToChannel:(NSString*)channelName withColor:(UIColor*)color;

/// Channel to use if channelName is nil
/// Defaults to @"Log"
@property (strong, nonatomic) NSString* defaultChannelName;

@end

void EKNLogChannel(NSString* channel, NSString* formatHTML, ...);
void EKNLogChannelImage(NSString* channel, UIImage* image);
void EKNLogChannelColor(NSString* channel, UIColor* color);

// These variants use the defaultChannelName
void EKNLog(NSString* formatHTML, ...);
void EKNLogImage(UIImage* image);
void EKNLogColor(UIColor* color);

@protocol EKNHTMLLogging <NSObject>

/// Convenient way to generate HTML from an object
- (NSString*)ekn_html;

@end

/// Default implementation of ekn_html. Just an html-encoded version of -[NSObject description]
@interface NSObject (EKNLogger) <EKNHTMLLogging>

@end

/// Customized implementation of HTML generation. Generates a swatch
@interface UIColor (EKNLogger) <EKNHTMLLogging>
@end

/// Customized implementation of HTML generation.
/// Converts to an img tag with the relevant data
@interface UIImage (EKNLogger) <EKNHTMLLogging>
@end