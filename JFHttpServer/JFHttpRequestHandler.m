//
//  JFHttpRequestHandler.m
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import "JFHttpRequestHandler.h"

static NSArray *kDefaultHttpMethods;

@interface JFHttpRequestHandler ()

@property (strong, nonatomic) NSRegularExpression *uriRegex;

@end

@implementation JFHttpRequestHandler

+ (void)initialize
{
    kDefaultHttpMethods = @[@"GET"];
}

+ (instancetype)requestHandlerWithAction:(SEL)action target:(id)target uriPattern:(NSString *)uriPattern
{
    return [self requestHandlerWithAction:action target:target uriPattern:uriPattern httpMethods:kDefaultHttpMethods];
}

+ (instancetype)requestHandlerWithAction:(SEL)action target:(id)target uriPattern:(NSString *)uriPattern httpMethods:(NSArray *)httpMethods
{
    JFHttpRequestHandler *handler = [[JFHttpRequestHandler alloc] initWithAction:action target:target uriPattern:uriPattern httpMethods:httpMethods];
    return handler;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _httpMethods = kDefaultHttpMethods;
    }

    return self;
}

- (id)initWithAction:(SEL)action target:(id)target uriPattern:(NSString *)uriPattern
{
    return [self initWithAction:action target:target uriPattern:uriPattern httpMethods:kDefaultHttpMethods];
}

- (id)initWithAction:(SEL)action target:(id)target uriPattern:(NSString *)uriPattern httpMethods:(NSArray *)httpMethods
{
    self = [super init];
    if (self != nil) {
        self.action = action;
        self.target = target;
        self.uriPattern = uriPattern;
        self.httpMethods = httpMethods;
    }

    return self;
}

- (void)dealloc
{
    self.target = nil;
    self.uriPattern = nil;
    self.httpMethods = nil;
}

- (void)setUriPattern:(NSString *)uriPattern
{
    _uriPattern = [uriPattern copy];
    _uriRegex = [NSRegularExpression regularExpressionWithPattern:_uriPattern options:0 error:NULL];
}

@end
