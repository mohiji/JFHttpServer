//
//  JFHttpBuffer.h
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFHttpBuffer : NSObject

@property (readonly, nonatomic) size_t size;
@property (readonly, nonatomic) char*  buffer;

- (void)appendString:(NSString*)str;

@end
