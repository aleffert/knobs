//
//  EKNChunkConnection.m
//  Knobs
//
//  Created by Akiva Leffert on 11/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNChunkConnection.h"

#import "EKNChunkReader.h"
#import "EKNChunkWriter.h"

@interface EKNChunkConnection () <EKNChunkReaderDelegate, EKNChunkWriterDelegate>

@property (strong, nonatomic) EKNChunkReader* reader;
@property (strong, nonatomic) EKNChunkWriter* writer;

@end

@implementation EKNChunkConnection

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    self = [super init];
    
    self.reader = [[EKNChunkReader alloc] initWithInputStream:inputStream];
    self.reader.delegate = self;
    self.writer = [[EKNChunkWriter alloc] initWithOutputStream:outputStream];
    self.writer.delegate = self;
    
    return self;
}

- (id)initWithNetService:(NSNetService*)service {
    NSInputStream* inputStream = nil;
    NSOutputStream* outputStream = nil;
    
    [service getInputStream:&inputStream outputStream:&outputStream];
    
    self = [self initWithInputStream:inputStream outputStream:outputStream];
    
    return self;
}

- (void)open {
    [self.reader open];
    [self.writer open];
}

- (void)close {
    [self.reader close];
    [self.writer close];
}

- (void)sendData:(NSData *)data withHeader:(NSDictionary *)header {
    [self.writer sendBodyData:data withHeader:header];
}

- (void)chunkReader:(EKNChunkReader *)reader readChunkWithData:(NSData *)data header:(NSDictionary *)header {
    [self.delegate connection:self receivedData:data withHeader:header];
}

- (void)chunkWriterDidCloseStream:(EKNChunkWriter *)writer {
    [self.delegate connectionClosed:self];
    [self.reader close];
    self.reader = nil;
    self.writer = nil;
}

- (void)chunkReaderDidCloseStream:(EKNChunkReader *)reader {
    [self.delegate connectionClosed:self];
    [self.writer close];
    self.reader = nil;
    self.writer = nil;
}

@end
