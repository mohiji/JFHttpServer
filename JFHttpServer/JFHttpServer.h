//
//  JFHttpServer.h
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFHttpRequestHandler.h"
#import "JFHttpRequest.h"
#import "JFHttpReply.h"
@class JFHttpConnection;

@interface JFHttpServer : NSObject

- (void)addRequestHandler:(JFHttpRequestHandler*)handler;
- (void)addRequestHandler:(SEL)selector atObject:(id)obj forUriPattern:(NSString*)pattern;
- (void)addRequestHandler:(SEL)selector atObject:(id)obj forUriPattern:(NSString*)pattern httpMethods:(NSArray*)methods;

- (void)startListeningOnPort:(int)port;
- (void)stopListening;

- (void)removeConnection:(JFHttpConnection*)connection;

- (JFHttpRequestHandler*)requestHandlerForUri:(NSString*)uri;

@end
