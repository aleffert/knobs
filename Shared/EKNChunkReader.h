//
//  EKNChunkReader.h
//  Knobs
//
//  Created by Akiva Leffert on 11/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EKNChunkReaderDelegate;

@interface EKNChunkReader : NSObject

- (id)initWithInputStream:(NSInputStream*)stream;

@property (assign, nonatomic) id <EKNChunkReaderDelegate> delegate;

- (void)open;
- (void)close;

@end


@protocol EKNChunkReaderDelegate <NSObject>
- (void)chunkReaderDidCloseStream:(EKNChunkReader *)reader;
- (void)chunkReader:(EKNChunkReader*)reader readChunkWithData:(NSData*)data header:(NSDictionary*)header;

@end