//
//  EKNChunkWriter.h
//  Knobs
//
//  Created by Akiva Leffert on 11/26/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EKNChunkWriterDelegate;

@interface EKNChunkWriter : NSObject

- (id)initWithOutputStream:(NSOutputStream*)stream;

@property (assign, nonatomic) id <EKNChunkWriterDelegate> delegate;

- (void)open;
- (void)close;

- (void)sendBodyData:(NSData*)data withHeader:(NSDictionary*)header;

@end


@protocol EKNChunkWriterDelegate <NSObject>

- (void)chunkWriterDidCloseStream:(EKNChunkWriter*)writer;

@end