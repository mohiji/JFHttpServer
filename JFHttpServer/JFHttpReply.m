//
//  JFHttpReply.m
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import "JFHttpReply.h"

@interface JFHttpReply ()

@property (strong, nonatomic) NSMutableDictionary *headers;

@end

@implementation JFHttpReply

static NSDictionary *kHttpResponseStrings;

+ (void)initialize
{
    NSMutableDictionary *responseStrings = [NSMutableDictionary dictionary];

    // Fill the dictionary with the default form for a status line
    // Obviously not an exhaustive list.
    responseStrings[[NSNumber numberWithInteger:HTTPStatusOk]] = @"HTTP/1.1 200 OK";
    responseStrings[[NSNumber numberWithInteger:HTTPStatusCreated]] = @"HTTP/1.1 201 Created";
    responseStrings[[NSNumber numberWithInteger:HTTPStatusAccepted]] = @"HTTP/1.1 202 Accepted";
    responseStrings[[NSNumber numberWithInteger:HTTPStatusNonAuthoritative]]= @"HTTP/1.1 203 Non-Authoritative Information";
    responseStrings[[NSNumber numberWithInteger:HTTPStatusNoContent]] = @"HTTP/1.1 204 No Content";

    responseStrings[[NSNumber numberWithInteger:HTTPStatusMovedPermanently]] = @"HTTP/1.1 301 Moved Permanently";
    responseStrings[[NSNumber numberWithInteger:HTTPStatusTemporaryRedirect]] = @"HTTP/1.1 302 Moved Temporarily";
    responseStrings[[NSNumber numberWithInteger:HTTPStatusSeeOther]] = @"HTTP/1.1 303 See Other";
    responseStrings[[NSNumber numberWithInteger:HTTPStatusNotModified]] = @"HTTP/1.1 304 Not Modified";

    responseStrings[[NSNumber numberWithInteger:HTTPStatusNotFound]] = @"HTTP/1.1 404 Not Found";

    kHttpResponseStrings = [responseStrings copy];
}

+ (NSString*)statusLineForCode:(HTTPStatus)statusCode
{
    NSString *responseLine = kHttpResponseStrings[[NSNumber numberWithInteger:statusCode]];
    if (responseLine == nil) {
        // TODO: I should be caching these in the response strings dictionary so I can avoid re-creating
        // them, but I would need to make that thread-safe first.
        responseLine = [NSString stringWithFormat:@"HTTP/1.1 %lu", statusCode];
    }
    return responseLine;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.headers = [NSMutableDictionary dictionary];

        [self setHeaderField:@"Server" value:@"JFHttpServer 0.0.1"];

        self.statusCode = HTTPStatusOk;
        self.contentType = @"text/html; charset=utf-8";
    }

    return self;
}

- (void)dealloc
{
    self.headers = nil;
    self.content = nil;
    self.data = nil;
}

- (void)setHeaderField:(NSString *)field value:(NSString *)value
{
    if (field == nil) {
        return;
    }

    if (value == nil) {
        [_headers removeObjectForKey:field];
    } else {
        _headers[field] = value;
    }
}

- (void)setContentType:(NSString *)contentType
{
    _contentType = [contentType copy];
    [self setHeaderField:@"Content-Type" value:contentType];
}

- (NSString*)response
{
    NSMutableString *response = [NSMutableString stringWithFormat:@"%@\r\n", [JFHttpReply statusLineForCode:self.statusCode]];

    for (NSString *key in self.headers) {
        [response appendFormat:@"%@: %@\r\n", key, self.headers[key]];
    }
    [response appendString:@"\r\n"];

    if (self.content != nil) {
        [response appendString:self.content];
    }

    return response;
}

@end
