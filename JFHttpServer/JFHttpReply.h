//
//  JFHttpReply.h
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFHttpBuffer.h"

#define kHTTPStatusContinue           (100)
#define kHTTPStatusSwitchingProtocols (101)
#define kHTTPStatusProcessing         (102)

#define kHTTPStatusOk                 (200)
#define kHTTPStatusCreated            (201)
#define kHTTPStatusAccepted           (202)
#define kHTTPStatusNonAuthoritative   (203)
#define kHTTPStatusNoContent          (204)
#define kHTTPStatusResetContent       (205)
#define kHTTPStatusPartialContent     (206)
#define kHTTPStatusMultiStatus        (207)

#define kHTTPStatusNotFound           (404)

@interface JFHttpReply : NSObject

@property (assign, nonatomic) NSUInteger statusCode;

- (void)setHeaderField:(NSString*)field value:(NSString*)value;
- (void)fillBuffer:(JFHttpBuffer*)buffer;

@end
