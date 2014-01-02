//
//  EKNChunkReader.m
//  Knobs
//
//  Created by Akiva Leffert on 11/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import "EKNChunkReader.h"

typedef NS_ENUM(NSUInteger, EKNChunkReaderState) {
    EKNChunkReaderStateWaiting,
    EKNChunkReaderStateReadFrame
};

typedef struct {
    int64_t headerLength;
    int64_t bodyLength;
} EKNChunkReaderFrame;

@interface EKNChunkReader () <NSStreamDelegate>

@property (strong, nonatomic) NSInputStream* inputStream;
@property (strong, nonatomic) NSMutableData* accumulator;
@property (assign, nonatomic) int64_t bytesRemainingInChunk;

@property (assign, nonatomic) EKNChunkReaderState readState;
@property (assign, nonatomic) EKNChunkReaderFrame currentFrame;

@end

@implementation EKNChunkReader

- (id)initWithInputStream:(NSInputStream *)stream {
    self = [super init];
    self.inputStream = stream;
    self.inputStream.delegate = self;
    self.accumulator = [[NSMutableData alloc] initWithLength:[self headerSize]];
    self.bytesRemainingInChunk = [self headerSize];
    return self;
}

- (void)open {
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
}

- (void)close {
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (size_t)headerSize {
    return 2 * sizeof(int64_t);
}

- (void)readBytesIfPossible {
    while(self.inputStream.hasBytesAvailable) {
        switch (self.readState) {
            case EKNChunkReaderStateWaiting: {
                uint8_t* bytes = self.accumulator.mutableBytes;
                NSInteger readCount = [self.inputStream read:bytes maxLength:self.bytesRemainingInChunk];
                self.bytesRemainingInChunk = self.bytesRemainingInChunk - readCount;
                if(self.bytesRemainingInChunk == 0) {
                    EKNChunkReaderFrame frame = self.currentFrame;
                    [self.accumulator getBytes:&frame.headerLength range:NSMakeRange(0, sizeof(int64_t))];
                    [self.accumulator getBytes:&frame.bodyLength range:NSMakeRange(sizeof(int64_t), sizeof(int64_t))];
                    
                    frame.headerLength = CFSwapInt64BigToHost(frame.headerLength);
                    frame.bodyLength = CFSwapInt64BigToHost(frame.bodyLength);
                    self.currentFrame = frame;
                    self.bytesRemainingInChunk = frame.headerLength + frame.bodyLength;
                    self.accumulator = [[NSMutableData alloc] initWithLength:self.bytesRemainingInChunk];
                    self.readState = EKNChunkReaderStateReadFrame;
                }
                break;
            }
            case EKNChunkReaderStateReadFrame: {
                uint8_t* bytes = self.accumulator.mutableBytes + self.currentFrame.headerLength + self.currentFrame.bodyLength - self.bytesRemainingInChunk;
                NSInteger readCount = [self.inputStream read:bytes maxLength:self.bytesRemainingInChunk];
                self.bytesRemainingInChunk = self.bytesRemainingInChunk - readCount;
                if(self.bytesRemainingInChunk == 0) {
                    // finished a frame
                    NSData* headerData = [NSData dataWithBytesNoCopy:self.accumulator.mutableBytes length:self.currentFrame.headerLength freeWhenDone:NO];
                    NSDictionary* header = [NSKeyedUnarchiver unarchiveObjectWithData:headerData];
                    
                    uint8_t* bytes = self.accumulator.mutableBytes + self.currentFrame.headerLength;
                    NSData* bodyData = [NSData dataWithBytes:bytes length:self.currentFrame.bodyLength];
                    
                    [self.delegate chunkReader:self readChunkWithData:bodyData header:header];
                    
                    // reset
                    self.readState = EKNChunkReaderStateWaiting;
                    self.bytesRemainingInChunk = [self headerSize];
                    self.accumulator = [[NSMutableData alloc] initWithLength:[self headerSize]];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            [self readBytesIfPossible];
            break;
        case NSStreamEventErrorOccurred:
        case NSStreamEventEndEncountered:
            [self.delegate chunkReaderDidCloseStream:self];
            break;
        case NSStreamEventOpenCompleted:
            // Do nothing
            break;
        default:
            NSLog(@"event is %ld", (long)eventCode);
            break;
    }
}

@end
