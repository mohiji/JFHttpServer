//
//  JFHttpConnection.m
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import "JFHttpConnection.h"
#import "JFHttpServer.h"
#import "JFHttpRequest.h"
#import "JFHttpReply.h"
#import "NSString+BufferAndLength.h"
#include "http11_parser.h"

#define BUFFER_SIZE (1024)

static NSString *kHttpContentLength = @"content-length";
static NSString *kHttpHost = @"host";

static void header_field_cb(void *data, const char *field, size_t flen, const char *value, size_t vlen);
static void request_method_cb(void *data, const char *at, size_t length);
static void uri_cb(void *data, const char *at, size_t length);
static void fragment_cb(void *data, const char *at, size_t length);
static void path_cb(void *data, const char *at, size_t length);
static void query_string_cb(void *data, const char *at, size_t length);
static void http_version_cb(void *data, const char *at, size_t length);
static void header_done_cb(void *data, const char *at, size_t length);

@interface JFHttpConnection ()
{
    http_parser _parser;
    int _socket;

    char _readBuffer[BUFFER_SIZE];
    size_t _numParsed;

    BOOL _shouldClose;
}

@property (strong, nonatomic) dispatch_source_t readSource;
@property (strong, nonatomic) dispatch_source_t writeSource;

@property (strong, nonatomic) JFHttpRequest *currentRequest;
@property (copy  , nonatomic) NSString *currentResponse;
@property (assign, atomic) NSUInteger socketReferenceCount;

- (void)startWithSocket:(int)s;
- (void)readEvent;
- (void)readCancel;
- (void)writeEvent;
- (void)writeCancel;

- (void)addSocketRef;
- (void)decSocketRef;

@end

@implementation JFHttpConnection

- (id)init
{
    self = [super init];
    if (self != nil) {
        http_parser_init(&_parser);

        _parser.http_field = header_field_cb;
        _parser.request_method = request_method_cb;
        _parser.request_uri = uri_cb;
        _parser.fragment = fragment_cb;
        _parser.request_path = path_cb;
        _parser.query_string = query_string_cb;
        _parser.http_version = http_version_cb;
        _parser.header_done = header_done_cb;

        _shouldClose = NO;
    }
    return self;
}

- (void)dealloc
{
    self.currentRequest = nil;
    self.currentResponse = nil;
}

- (void)startWithSocket:(int)s
{
    _socket = s;
    fcntl(_socket, F_SETFL, O_NONBLOCK);

    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, _socket, 0, globalQueue);
    if (self.readSource == NULL) {
        NSLog(@"JFHttpConnection -startWithSocket: Failed to create a dispatch source for socket %d", _socket);
        close(_socket);
        _socket = -1;
        [self.server removeConnection:self];
        return;
    }

    dispatch_source_set_event_handler(self.readSource, ^{
        [self readEvent];
    });

    dispatch_source_set_cancel_handler(self.readSource, ^{
        [self readCancel];
    });

    [self addSocketRef];
    dispatch_resume(self.readSource);
}

- (void)readEvent;
{
    NSLog(@"JFHttpConnection - read event handler");

    // Just starting a new request?
    if (_currentRequest == nil) {
        _currentRequest = [[JFHttpRequest alloc] init];
        http_parser_init(&_parser);
        _parser.data = (__bridge void *)(_currentRequest);
    }

    size_t estimated = dispatch_source_get_data(self.readSource) + 1;
    size_t actual = read(_socket, _readBuffer, estimated);
    if (actual == -1) {
        NSLog(@"JFHttpConnection - read() failed, bailing out");
        dispatch_source_cancel(self.readSource);
        self.readSource = nil;
    }
    _numParsed = http_parser_execute(&_parser, _readBuffer, actual, _numParsed);

    int finished = http_parser_finish(&_parser);
    if (finished) {
        // TODO: Figure out the proper logic for whether or not a connection should be closed.
        _shouldClose = YES;
//        NSString *closeHeader = [_currentRequest valueForHeader:@"connection"];
//        if (closeHeader != nil && [closeHeader caseInsensitiveCompare:@"close"] == NSOrderedSame) {
//            _shouldClose = YES;
//        }

        JFHttpReply *reply = [[JFHttpReply alloc] init];
        reply.statusCode = HTTPStatusNotFound;
        reply.contentType = nil;
        [reply setHeaderField:@"Connection" value:@"close"];
        self.currentResponse = [reply response];
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, _socket, 0, globalQueue);
        [self addSocketRef];
        if (self.writeSource == nil) {
            NSLog(@"JFHttpConnection -handleRead: Failed to create a dispatch source to write a response to socket %d", _socket);

            dispatch_source_cancel(self.readSource);
            self.readSource = nil;

            close(_socket);
            _socket = -1;

            [self.server removeConnection:self];
            return;
        }

        dispatch_source_set_event_handler(self.writeSource, ^{
            [self writeEvent];
        });

        dispatch_source_set_cancel_handler(self.writeSource, ^{
            [self writeCancel];
        });

        dispatch_resume(self.writeSource);

        if (_shouldClose) {
            NSLog(@"JFHttpConnection - cancelling the read handler");
            dispatch_source_cancel(self.readSource);
            self.readSource = nil;
        }
    }
}

- (void)readCancel
{
    NSLog(@"JFHttpConnection - read cancel handler");
    [self decSocketRef];
}

- (void)writeEvent
{
    NSLog(@"JFHttpConnection - write event handler");
    const char *writeBuffer = [self.currentResponse cStringUsingEncoding:NSUTF8StringEncoding];
    const size_t len = strlen(writeBuffer) + 1;

    write(_socket, writeBuffer, len);

    dispatch_source_cancel(self.writeSource);
    self.writeSource = nil;
}

- (void)writeCancel
{
    NSLog(@"JFHttpConnection - write cancel handler");
    self.currentResponse = nil;
    self.currentRequest = nil;
    [self decSocketRef];
}

- (void)addSocketRef
{
    self.socketReferenceCount = self.socketReferenceCount + 1;
     NSLog(@"JFHttpConnection -addSocketRef - Socket reference count is now %lu.", self.socketReferenceCount);
}

- (void)decSocketRef
{
    self.socketReferenceCount = self.socketReferenceCount - 1;

    NSLog(@"JFHttpConnection -decSocketRef - Socket reference count is now %lu.", self.socketReferenceCount);
    if (self.socketReferenceCount == 0) {
        NSLog(@"JFHttpConnection - closing socket %d", _socket);
        close(_socket);
        _socket = -1;
    }
}

@end

static void header_field_cb(void *data, const char *field, size_t flen,
                            const char *value, size_t vlen)
{
    JFHttpRequest *request = (__bridge JFHttpRequest *)(data);

    NSString *fieldString = [NSString stringWithCString:field bufferLength:flen];
    NSString *valueString = [NSString stringWithCString:value bufferLength:vlen];
    [request setHeaderName:fieldString value:valueString];
}

static void request_method_cb(void *data, const char *at, size_t length)
{
    JFHttpRequest *request = (__bridge JFHttpRequest *)(data);
    request.method = [NSString stringWithCString:at bufferLength:length];
}

static void uri_cb(void *data, const char *at, size_t length)
{
    JFHttpRequest *request = (__bridge JFHttpRequest *)(data);
    request.uri = [NSString stringWithCString:at bufferLength:length];
}

static void fragment_cb(void *data, const char *at, size_t length)
{
    JFHttpRequest *request = (__bridge JFHttpRequest *)(data);
    request.fragment = [NSString stringWithCString:at bufferLength:length];
}

static void path_cb(void *data, const char *at, size_t length)
{
    JFHttpRequest *request = (__bridge JFHttpRequest *)(data);
    request.path = [NSString stringWithCString:at bufferLength:length];
}

static void query_string_cb(void *data, const char *at, size_t length)
{
    JFHttpRequest *request = (__bridge JFHttpRequest *)(data);
    request.queryString = [NSString stringWithCString:at bufferLength:length];
}

static void http_version_cb(void *data, const char *at, size_t length)
{
    JFHttpRequest *request = (__bridge JFHttpRequest *)(data);
    request.httpVersion = [NSString stringWithCString:at bufferLength:length];
}

static void header_done_cb(void *data, const char *at, size_t length)
{
    (void)at;
    (void)length;

    JFHttpRequest *request = (__bridge JFHttpRequest *)(data);

    NSString *contentLength = [request valueForHeader:kHttpContentLength];
    if (contentLength != nil) {
        request.contentLength = [contentLength integerValue];
    }

    NSString *hostname = [request valueForHeader:kHttpHost];
    NSRange range = [hostname rangeOfString:@":"];
    if (range.location == NSNotFound) {
        request.host = hostname;
    } else {
        range.length = range.location;
        range.location = 0;
        request.host = [hostname substringWithRange:range];
    }
}
