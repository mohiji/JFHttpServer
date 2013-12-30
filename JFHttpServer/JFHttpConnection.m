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
    dispatch_source_t _readSource;

    char _readBuffer[BUFFER_SIZE];
    size_t _numParsed;
}

@property (strong, nonatomic) JFHttpRequest *currentRequest;

- (void)startWithSocket:(int)s;
- (void)handleRead;

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
    }
    return self;
}

- (void)dealloc
{

}

- (void)startWithSocket:(int)s
{
    _socket = s;
    fcntl(_socket, F_SETFL, O_NONBLOCK);

    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, _socket, 0, globalQueue);
    if (_readSource == NULL) {
        NSLog(@"JFHttpConnection -startWithSocket: Failed to create a dispatch source for socket %d", _socket);
        close(_socket);
        _socket = -1;
        [self.server removeConnection:self];
        return;
    }

    dispatch_source_set_event_handler(_readSource, ^{
        [self handleRead];
    });

    dispatch_source_set_cancel_handler(_readSource, ^{
        close(_socket);
        _readSource = NULL;
        [self.server removeConnection:self];
    });

    dispatch_resume(_readSource);
}

- (void)handleRead
{
    // Just starting a new request?
    if (_currentRequest == nil) {
        _currentRequest = [[JFHttpRequest alloc] init];
        http_parser_init(&_parser);
        _parser.data = (__bridge void *)(_currentRequest);
    }

    size_t estimated = dispatch_source_get_data(_readSource) + 1;
    size_t actual = read(_socket, _readBuffer, estimated);
    _numParsed = http_parser_execute(&_parser, _readBuffer, actual, _numParsed);

    int finished = http_parser_finish(&_parser);
    if (finished) {
        // Done with this request.
        NSLog(@"Finished reading a request.");
        NSLog(@"Host: %@", _currentRequest.host);
        NSLog(@"Method: %@", _currentRequest.method);
        NSLog(@"Version: %@", _currentRequest.httpVersion);
        NSLog(@"URI: %@", _currentRequest.uri);
        NSLog(@"Path: %@", _currentRequest.path);
        NSLog(@"Query string: %@", _currentRequest.queryString);
        NSLog(@"Fragment: %@", _currentRequest.fragment);
        NSLog(@"Content length: %ld", (long)_currentRequest.contentLength);

        NSLog(@"Headers:");
        NSDictionary *allHeaders = _currentRequest.allHeaders;
        for (NSString *key in allHeaders) {
            NSLog(@"  %@: %@", key, allHeaders[key]);
        }


        _currentRequest = nil;
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
