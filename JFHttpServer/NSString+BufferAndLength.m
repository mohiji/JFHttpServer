//
//  NSString+BufferAndLength.m
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/23/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import "NSString+BufferAndLength.h"


@implementation NSString (BufferAndLength)

+ (NSString*)stringWithCString:(const char *)str bufferLength:(size_t)length
{
    // TODO: Maybe this buffer should be allocated once and kept around
    char *buffer = malloc(length);
    memcpy(buffer, str, length);
    buffer[length] = 0;

    NSString *newString = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    free(buffer);
    return newString;
}

@end
