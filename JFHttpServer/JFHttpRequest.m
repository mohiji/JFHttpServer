//
//  JFHttpRequest.m
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import "JFHttpRequest.h"

@interface JFHttpRequest ()

@property (strong, nonatomic) NSMutableDictionary *headers;

@end

@implementation JFHttpRequest

- (id)init
{
    self = [super init];
    if (self != nil) {
        _headers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    _headers = nil;
}

- (void)setHeaderName:(NSString *)name value:(NSString *)value
{
    [_headers setObject:value forKey:[name lowercaseString]];
}

- (NSString*)valueForHeader:(NSString *)field
{
    return [_headers objectForKey:[field lowercaseString]];
}

- (NSDictionary*)allHeaders
{
    return [_headers copy];
}

@end
