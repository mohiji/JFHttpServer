//
//  NSString+BufferAndLength.h
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/23/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BufferAndLength)
+ (NSString*)stringWithCString:(const char*)str bufferLength:(size_t)length;
@end
