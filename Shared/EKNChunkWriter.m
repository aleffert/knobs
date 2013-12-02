//
//  EKNChunkWriter.m
//  Knobs
//
//  Created by Akiva Leffert on 11/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNChunkWriter.h"

@interface EKNQueuedChunk : NSObject

@property (strong, nonatomic) NSData* data;
@property (assign, nonatomic) uint64_t offset;

@end

@implementation EKNQueuedChunk

@end

@interface EKNChunkWriter () <NSStreamDelegate>

@property (strong, nonatomic) NSMutableArray* messageQueue;
@property (strong, nonatomic) NSOutputStream* outputStream;

@end

@implementation EKNChunkWriter

- (id)initWithOutputStream:(NSOutputStream *)stream {
    self = [super init];
    self.outputStream = stream;
    self.outputStream.delegate = self;
    
    self.messageQueue = [NSMutableArray array];
    return self;
}

- (void)open {
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
}

- (void)close {
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)sendMoreDataIfPossible {
    while(self.outputStream.hasSpaceAvailable && self.messageQueue.count > 0) {
        EKNQueuedChunk* chunk = [self.messageQueue objectAtIndex:0];
        const uint8_t* bytes = chunk.data.bytes;
        NSUInteger bytesWritten = [self.outputStream write:bytes + chunk.offset maxLength:chunk.data.length - chunk.offset];
        chunk.offset += bytesWritten;
        if(chunk.offset == chunk.data.length) {
            [self.messageQueue removeObjectAtIndex:0];
        }
    }
}

// FORMAT:
// 64-bit length of header (big endian)
// 64-bit length of body (big endian)
// header data
// body data
// For easy reading use EKNChunkedReader

- (void)sendBodyData:(NSData *)data withHeader:(NSDictionary *)header {
    NSData* headerData = [NSKeyedArchiver archivedDataWithRootObject:header];
    uint64_t headerLength = CFSwapInt64HostToBig(headerData.length);
    uint64_t bodyLength = CFSwapInt64HostToBig(data.length);
    
    NSMutableData* buffer = [[NSMutableData alloc] initWithCapacity:sizeof(headerLength) + sizeof(bodyLength) + headerData.length + data.length];
    [buffer appendBytes:&headerLength length:sizeof(headerLength)];
    [buffer appendBytes:&bodyLength length:sizeof(bodyLength)];
    [buffer appendData:headerData];
    [buffer appendData:data];
//    [self.buffer appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    EKNQueuedChunk* chunk = [[EKNQueuedChunk alloc] init];
    chunk.data = buffer;
    chunk.offset = 0;
    
    [self.messageQueue addObject:chunk];
    
    [self sendMoreDataIfPossible];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable:
            [self sendMoreDataIfPossible];
            break;
        case NSStreamEventErrorOccurred:
        case NSStreamEventEndEncountered:
            [self.delegate chunkWriterDidCloseStream:self];
            break;
        case NSStreamEventOpenCompleted:
            // Do nothing
            break;
        default:
            NSLog(@"Unhandled event %ld", (long)eventCode);
            break;
    }
}

@end
