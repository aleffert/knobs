//
//  EKNConnectionListener.m
//  Knobs-iOS
//
//  Created by Akiva Leffert on 12/21/13.
//  Copyright (c) 2013 Akiva Leffert. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>

#import "EKNConnectionListener.h"

@interface EKNConnectionListener ()

@property (assign, nonatomic) CFSocketRef socket;
@property (assign, nonatomic) CFRunLoopSourceRef source;
@property (nonatomic) uint16_t port;

- (void)acceptedConnectionWithSocketHandle:(CFSocketNativeHandle)socket;

@end

void EKNConnectionAccepted(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

void EKNConnectionAccepted(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    EKNConnectionListener* listener = (__bridge EKNConnectionListener*)info;

    CFSocketNativeHandle socketHandle = *(CFSocketNativeHandle*)data;
    [listener acceptedConnectionWithSocketHandle:socketHandle];
}

@implementation EKNConnectionListener

- (void)start {
    CFSocketContext socketCtxt = {0, (__bridge void*)self, NULL, NULL, NULL};
    self.socket = CFSocketCreate(NULL, PF_INET6, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, EKNConnectionAccepted, &socketCtxt);
    
    fcntl(CFSocketGetNative(self.socket), F_SETFL, O_NONBLOCK);
    
    int reuseEnabled = YES;
    setsockopt(CFSocketGetNative(self.socket), SOL_SOCKET, SO_REUSEADDR, &reuseEnabled, sizeof(reuseEnabled));
    
    struct sockaddr_in6 address;
    memset(&address, 0, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
    address.sin6_port = 0;
    address.sin6_flowinfo = 0;
    address.sin6_addr = in6addr_any;
    
    NSData *addressData = [NSData dataWithBytes:&address length:sizeof(address)];
    CFSocketSetAddress(self.socket, (__bridge CFDataRef)addressData);
    
    NSData *boundSocketData = (__bridge_transfer NSData*)CFSocketCopyAddress(self.socket);
    memcpy(&address, [boundSocketData bytes], [boundSocketData length]);
    
    self.port = ntohs(address.sin6_port);
    
    CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    self.source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.socket, 0);
    CFRunLoopAddSource(currentRunLoop, self.source, kCFRunLoopCommonModes);
}

- (void)stop {
    CFRunLoopRemoveSource(CFRunLoopGetMain(), self.source, kCFRunLoopDefaultMode);
    CFSocketInvalidate(self.socket);
    CFRelease(self.socket);
    self.socket = NULL;
    self.source = NULL;
}

- (void)acceptedConnectionWithSocketHandle:(CFSocketNativeHandle)socket {
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocket(NULL, socket, &readStream, &writeStream);
    [self.delegate connectionListener:self didAcceptConnectionWithInputStream:(__bridge_transfer NSInputStream*)readStream outputStream:(__bridge_transfer NSOutputStream*)writeStream];
}

@end
