//
//  JFHttpRequestHandler.h
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFHttpRequestHandler : NSObject

+ (instancetype)requestHandlerWithAction:(SEL)action target:(id)target uriPattern:(NSString*)uriPattern;
+ (instancetype)requestHandlerWithAction:(SEL)action target:(id)target uriPattern:(NSString*)uriPattern httpMethods:(NSArray*)httpMethods;

- (id)initWithAction:(SEL)action target:(id)target uriPattern:(NSString*)uriPattern;
- (id)initWithAction:(SEL)action target:(id)target uriPattern:(NSString*)uriPattern httpMethods:(NSArray*)httpMethods;

@property (assign, nonatomic) SEL action;
@property (weak  , nonatomic) id  target;
@property (copy  , nonatomic) NSString *uriPattern;
@property (copy  , nonatomic) NSArray *httpMethods;

@property (readonly, nonatomic) NSRegularExpression *uriRegex;

@end
