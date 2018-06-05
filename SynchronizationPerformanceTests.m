//
//  PerformanceTests.m
//  SomeAlgosTests
//
//  Created by Luke Parham on 6/3/18.
//  Copyright © 2018 Luke Parham. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Cache.h"

#include <dispatch/dispatch.h>

#define ITERATIONS 10000

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@interface SynchronizationPerformanceTests : XCTestCase

@end

@implementation SynchronizationPerformanceTests

- (void)testTimeForInserts
{
    Cache *cache = [[Cache alloc] init];
    
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    for (int i = 0; i < ITERATIONS; i++) {
        [keys addObject:[NSString stringWithFormat:@"key%d", i]];
        [values addObject:[NSString stringWithFormat:@"value%d", i]];
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    CFTimeInterval startTime = CACurrentMediaTime();
    for (int i = 0; i < ITERATIONS; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            [cache setObject:values[i] forKey:keys[i]];
        });
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    CFTimeInterval endTime = CACurrentMediaTime();

    NSLog(@"Total time for inserting %@ times: averaged %g ns", @(ITERATIONS), (((endTime - startTime)*1000000000))/ITERATIONS);

    // Make sure the values were added correctly
    for (NSString *key in keys) {
        NSInteger index = [keys indexOfObject:key];
        XCTAssert([values[index] isEqualToString:[cache objectForKey:key]]);
    }
}

- (void)testTimeForConcurrentInsertsAndReads {
    Cache *cache = [[Cache alloc] init];
    
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    for (int i = 0; i < ITERATIONS; i++) {
        [keys addObject:[NSString stringWithFormat:@"key%d", i]];
        [values addObject:[NSString stringWithFormat:@"value%d", i]];
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    CFTimeInterval startTime = CACurrentMediaTime();
    for (int i = 0; i < ITERATIONS; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            [cache setObject:values[i] forKey:keys[i]];
        });
    }
    
    for (int i = 0; i < ITERATIONS; i++) {
        __block id object;
        dispatch_group_async(group, dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            object = [cache objectForKey:keys[i]];
        });
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    CFTimeInterval endTime = CACurrentMediaTime();
    
    NSLog(@"Total time for %@ iterations: %g ns", @(ITERATIONS), ((endTime - startTime)*1000000));
    
    for (NSString *key in keys) {
        NSInteger index = [keys indexOfObject:key];
        XCTAssert([values[index] isEqualToString:[cache objectForKey:key]]);
    }
}

@end
