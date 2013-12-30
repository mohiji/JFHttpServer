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

- (id)init
{
    self = [super init];
    if (self != nil) {
        _headers = [NSMutableDictionary dictionary];

        [self setHeaderField:@"Server" value:@"JFHttpServer 0.0.1"];
    }

    return self;
}

- (void)dealloc
{
    _headers = nil;
}

- (void)setHeaderField:(NSString *)field value:(NSString *)value
{
    _headers[field] = value;
}

@end
