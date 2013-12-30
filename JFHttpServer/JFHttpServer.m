//
//  JFHttpServer.m
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import "JFHttpServer.h"
#import "JFHttpConnection.h"
#include <sys/socket.h>
#include <arpa/inet.h>

static int IPv4SocketOnPort(int port)
{
    int s = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in addr4 = { sizeof(addr4), AF_INET, htons(port), { INADDR_ANY }, { 0 }};
    int yes = 1;

    int result = setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    if (result == -1) {
        NSLog(@"IPv4SocketOnPort: setsockopt failed with errno: %d", errno);
        goto error;
    }

    result = bind(s, (void*)&addr4, sizeof(addr4));
    if (result == -1) {
        NSLog(@"IPv4SocketOnPort: bind failed with errno: %d", errno);
        goto error;
    }

    result = listen(s, 16);
    if (result == -1) {
        NSLog(@"IPv4SocketOnPort: listen failed with errno: %d", errno);
        goto error;

    }

    return s;

error:
    close(s);
    return -1;
}

@interface JFHttpServer ()
{
    int _listenPort;
    int _listenSocket;
    dispatch_source_t _listenSource;
}

@property (strong, nonatomic) NSMutableArray *requestHandlers;
@property (strong, nonatomic) NSMutableArray *connections;

- (void)acceptConnectionOnSocket:(int)s;

@end

@implementation JFHttpServer

- (id)init
{
    self = [super init];
    if (self != nil) {
        _listenPort = -1;
        _listenSocket = -1;
    }
    return self;
}

- (void)dealloc
{
    if (_listenSocket != -1) {
        [self stopListening];
    }
}

- (void)addRequestHandler:(JFHttpRequestHandler *)handler
{
    [_requestHandlers addObject:handler];
}

- (void)addRequestHandler:(SEL)selector atObject:(id)obj forUriPattern:(NSString *)pattern
{
    JFHttpRequestHandler *handler = [JFHttpRequestHandler requestHandlerWithAction:selector target:obj uriPattern:pattern];
    [self addRequestHandler:handler];
}

- (void)addRequestHandler:(SEL)selector atObject:(id)obj forUriPattern:(NSString *)pattern httpMethods:(NSArray *)methods
{
    JFHttpRequestHandler *handler = [JFHttpRequestHandler requestHandlerWithAction:selector target:obj uriPattern:pattern httpMethods:methods];
    [self addRequestHandler:handler];
}

- (void)startListeningOnPort:(int)port
{
    NSLog(@"JFHttpServer -startListeningOnPort:%d", port);
    if (port <= 0 || port > 65535) {
        NSLog(@"JFHttpServer -startListeningOnPort: Invalid port number %d", port);
        return;
    }

    _listenSocket = IPv4SocketOnPort(port);
    if (_listenSocket == -1) {
        NSLog(@"-startListeningOnPort: Unable to create a listening socket on port %d.", port);
        return;
    }
    _listenPort = port;

    _listenSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, _listenSocket, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_event_handler(_listenSource, ^{
        [self acceptConnectionOnSocket:_listenSocket];
    });

    dispatch_source_set_cancel_handler(_listenSource, ^{
        NSLog(@"Closing the listening socket.");
        close(_listenSocket);
    });

    dispatch_resume(_listenSource);
}

- (void)stopListening
{
    dispatch_source_cancel(_listenSource);
    _listenSocket = -1;
}

- (void)acceptConnectionOnSocket:(int)s
{
    struct sockaddr addr;
    socklen_t addrlen = sizeof(addr);
    int new_socket = accept(s, &addr, &addrlen);

    NSLog(@"JFHttpServer -acceptConnection: New connection on socket %d, new socket is %d", s, new_socket);

    JFHttpConnection *connection = [[JFHttpConnection alloc] init];
    connection.server = self;
    [connection startWithSocket:new_socket];
}

- (void)removeConnection:(JFHttpConnection *)connection
{
    [_connections removeObject:connection];
}

- (JFHttpRequestHandler*)requestHandlerForUri:(NSString *)uri
{
    for (JFHttpRequestHandler *handler in _requestHandlers) {
        if ([handler.uriRegex numberOfMatchesInString:uri options:0 range:NSMakeRange(0, uri.length)] > 0) {
            return handler;
        }
    }
    return nil;
}

@end
