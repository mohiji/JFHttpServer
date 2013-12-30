//
//  JFHttpRequest.h
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFHttpRequest : NSObject

@property (copy, nonatomic) NSString *method;
@property (copy, nonatomic) NSString *httpVersion;
@property (copy, nonatomic) NSString *uri;
@property (copy, nonatomic) NSString *path;
@property (copy, nonatomic) NSString *queryString;
@property (copy, nonatomic) NSString *fragment;
@property (copy, nonatomic) NSString *host;

@property (assign, nonatomic) NSInteger contentLength;

@property (readonly, nonatomic) NSDictionary *allHeaders;

- (void)setHeaderName:(NSString*)name value:(NSString*)value;
- (NSString*)valueForHeader:(NSString*)field;

@end
