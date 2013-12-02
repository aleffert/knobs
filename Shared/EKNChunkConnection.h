//
//  EKNChunkConnection.h
//  Knobs
//
//  Created by Akiva Leffert on 11/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EKNChunkConnectionDelegate;

@interface EKNChunkConnection : NSObject

- (id)initWithInputStream:(NSInputStream*)inputStream outputStream:(NSOutputStream*)outputStream;
- (id)initWithNetService:(NSNetService*)service;

@property (weak, nonatomic) id <EKNChunkConnectionDelegate> delegate;

- (void)open;
- (void)close;

- (void)sendData:(NSData*)data withHeader:(NSDictionary*)header;


@end

@protocol EKNChunkConnectionDelegate <NSObject>

- (void)connectionClosed:(EKNChunkConnection*)connection;
- (void)connection:(EKNChunkConnection*)connection receivedData:(NSData*)data withHeader:(NSDictionary*)header;

@end
