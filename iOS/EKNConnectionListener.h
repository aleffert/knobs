//
//  EKNConnectionListener.h
//  Knobs-iOS
//
//  Created by Akiva Leffert on 12/21/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EKNConnectionListenerDelegate;

@interface EKNConnectionListener : NSObject

@property (weak, nonatomic) id <EKNConnectionListenerDelegate> delegate;

/// Only valid if the server is started
@property (readonly, nonatomic) uint16_t port;

- (void)start;
- (void)stop;

@end

@protocol EKNConnectionListenerDelegate <NSObject>

- (void)connectionListener:(EKNConnectionListener*)listener didAcceptConnectionWithInputStream:(NSInputStream*)inputStream outputStream:(NSOutputStream*)outputStream;

@end