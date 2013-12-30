//
//  JFHttpReply.h
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFHttpStatusCodes.h"

@interface JFHttpReply : NSObject

@property (copy  , nonatomic) NSString *content;
@property (copy  , nonatomic) NSData *data;

@property (assign, nonatomic) HTTPStatus statusCode;
@property (copy  , nonatomic) NSString *contentType;

- (void)setHeaderField:(NSString*)field value:(NSString*)value;
- (NSString*)response;

@end
