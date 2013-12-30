//
//  JFHttpBuffer.m
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import "JFHttpBuffer.h"

static const size_t kDefaultCapacity = 128;

@interface JFHttpBuffer ()
{
    size_t _capacity;
    size_t _length;
    char *_buffer;
}

- (void)growBuffer;

@end

@implementation JFHttpBuffer

- (id)init
{
    self = [super init];
    if (self != nil) {
        _capacity = kDefaultCapacity;
        _length = 0;
        _buffer = malloc(_capacity);
    }

    return self;
}

- (void)dealloc
{
    free(_buffer);
}

- (size_t)size
{
    return _length;
}

- (char*)buffer
{
    return _buffer;
}

- (void)appendString:(NSString *)str
{
    const char *bytes = [str cStringUsingEncoding:NSUTF8StringEncoding];
    const size_t len = strlen(bytes);

    if (_length + len >= _capacity) {
        [self growBuffer];
    }

    memcpy(_buffer + _length, bytes, len);
    _length += len;
    _buffer[_length] = 0;
}

- (void)growBuffer
{
    const size_t newCapacity = _capacity * 1.5;
    _buffer = realloc(_buffer, newCapacity);
    _capacity = newCapacity;
}

@end
