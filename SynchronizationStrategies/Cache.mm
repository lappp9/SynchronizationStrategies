
#import "Cache.h"

#import "TestThread.h"

#import <UIKit/UIKit.h>

@interface Cache () {
    PERF::Mutex __instanceLock__;
    dispatch_queue_t _dispatch_queue;
    NSLock *_lock;
    
    NSMutableDictionary *_cache;
    NSMutableArray *_lruKeys;
    
    NSInteger _count;
}
@end

@implementation Cache

- (instancetype)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _cache = [NSMutableDictionary dictionary];
    _lruKeys = [NSMutableArray array];
    
    _lock = [[NSLock alloc] init];
    _dispatch_queue = dispatch_queue_create("com.Experiments.Cache", DISPATCH_QUEUE_CONCURRENT);
//    _dispatch_queue = dispatch_queue_create("com.Experiments.LRUCache", DISPATCH_QUEUE_SERIAL);

    return self;
}


- (void)setObject:(id)object forKey:(NSString *)key
{
//    PERF::MutexLocker l(__instanceLock__);
//    _cache[key] = object;

    dispatch_barrier_async(_dispatch_queue, ^{
        _cache[key] = object;
    });
    
//    [_lock lock];
//    _cache[key] = object;
//    [_lock unlock];
    
//    @synchronized (_cache) {
//        _cache[key] = object;
//    }
}

- (id)objectForKey:(NSString *)key
{
//    PERF::MutexLocker l(__instanceLock__);
//    return _cache[key];
    
    __block id object;
    dispatch_sync(_dispatch_queue, ^{
        object = _cache[key];
    });
    
//    __block id object;
//    @synchronized (_cache) {
//        object = _cache[key];
//    }

//    __block id object;
//    [_lock lock];
//    object = _cache[key];
//    [_lock unlock];
    
    return object;
}
- (void)removeObject:(id)object forKey:(NSString *)key
{
//    PERF::MutexLocker l(__instanceLock__);
//    [_cache removeObjectForKey:key];

    dispatch_barrier_async(_dispatch_queue, ^{
        [_cache removeObjectForKey:key];
    });

//    @synchronized (_cache) {
//        [_cache removeObjectForKey:key];
//    }

//    [_lock lock];
//    [_cache removeObjectForKey:key];
//    [_lock unlock];
}

@end
