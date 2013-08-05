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

+ (EKNLoggerPlugin*)sharedPlugin;


- (void)logToChannel:(NSString*)channelName withString:(NSString*)string;
- (void)logToChannel:(NSString*)channelName withHTMLString:(NSString*)string;
- (void)logToChannel:(NSString*)channelName withImage:(UIImage*)image;
- (void)logToChannel:(NSString*)channelName withColor:(UIColor*)color;

// Channel to use if channelName is nil
// Defaults to @"Log"
@property (strong, nonatomic) NSString* defaultChannelName;

@end

void EKNLogChannel(NSString* channel, NSString* formatHTML, ...);
void EKNLogChannelImage(NSString* channel, UIImage* image);
void EKNLogChannelColor(NSString* channel, UIColor* color);

// These variants use the defaultChannelName
void EKNLog(NSString* formatHTML, ...);
void EKNLogImage(UIImage* image);
void EKNLogColor(UIColor* color);

@interface NSObject (EKNLogger)

// Convenient way to generate HTML from an object
// Default is just an html-encoded version of -[NSObject description]
// Currently there are custom ones for UIImage and UIColor that generate visual representations
- (NSString*)ekn_html;

@end

