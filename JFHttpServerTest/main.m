//
//  main.m
//  JFHttpServerTest
//
//  Created by Jonathan Fischer on 12/24/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFHttpServer.h"
#import "JFHttpBuffer.h"

int main(int argc, const char * argv[])
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^/tasks/(\\d+)/update/(\\d+)$" options:0 error:NULL];
    NSString *test = @"/tasks/123/update/1";

    NSArray *matches = [regex matchesInString:test options:NSMatchingReportCompletion range:NSMakeRange(0, test.length)];
    if (matches == nil) {
        NSLog(@"matchesInString returned nil.");
    } else if (matches.count == 0) {
        NSLog(@"matchesInString returned 0 results.");
    } else {
        for (NSTextCheckingResult *result in matches) {
            NSUInteger numberOfRanges = result.numberOfRanges;
            NSLog(@"Number of ranges: %lu", numberOfRanges);

            for (NSUInteger rangeIndex = 0; rangeIndex < numberOfRanges; rangeIndex++) {
                NSLog(@"Match: %@", [test substringWithRange:[result rangeAtIndex:rangeIndex]]);
            }
        }
    }

    JFHttpServer *server = [[JFHttpServer alloc] init];
    [server startListeningOnPort:4242];

    dispatch_main();
    return 0;
}

