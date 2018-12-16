//
//  GCDTimer.m
//  Bilibili
//
//  Created by xulinfeng on 2018/4/24.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import "GCDTimer.h"
#import "GCDTimer+Private.h"

@implementation GCDTimer

+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats {
    GCDTimer *timer = [self timerWithInterval:interval target:target action:action userInfo:userInfo repeats:repeats];
    [timer schedule];
    
    return timer;
}

+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDTimer *timer))block {
    GCDTimer *timer = [self timerWithInterval:interval repeats:repeats block:block];
    [timer schedule];
    return timer;
}

+ (instancetype)timerWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats {
    return [[self alloc] initWithInterval:interval target:target action:action userInfo:userInfo repeats:repeats];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats {
    NSParameterAssert(target && action);
    if (self = [super init]) {
        _valid = YES;
        _interval = interval;
        _target = target;
        _action = action;
        _userInfo = userInfo;
        _repeats = repeats;
        _targetQueue = dispatch_get_main_queue();
        _lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

+ (instancetype)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDTimer *timer))block {
    return [[self alloc] initWithInterval:interval repeats:repeats block:block];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDTimer *timer))block {
    NSParameterAssert(block);
    if (self = [super init]) {
        _valid = YES;
        _interval = interval;
        _repeats = repeats;
        _block = [block copy];
        _targetQueue = dispatch_get_main_queue();
        _lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self invalidate];
}

#pragma mark - accessor

- (void)setLeeway:(NSTimeInterval)leeway {
    [_lock lock];
    
    if (_leeway != leeway) {
        _leeway = leeway;
        
        if (_timer) [self _reschedule];
    }
    [_lock unlock];
}

- (NSTimeInterval)leeway {
    NSTimeInterval leeway = 0;
    [_lock lock];
    
    leeway = _leeway;
    
    [_lock unlock];
    return leeway;
}

- (NSTimeInterval)interval {
    NSTimeInterval interval = 0;
    [_lock lock];
    
    interval = _interval;
    
    [_lock unlock];
    return interval;
}

- (BOOL)repeats{
    BOOL repeats = NO;
    [_lock lock];
    
    repeats = _repeats;
    
    [_lock unlock];
    return repeats;
}

- (BOOL)isValid {
    BOOL valid = NO;
    [_lock lock];

    valid = _valid;

    [_lock unlock];
    return valid;
}

- (void)setTargetQueue:(dispatch_queue_t)targetQueue {
    [_lock lock];
    
    if (_targetQueue != targetQueue) {
        _targetQueue = targetQueue ?: dispatch_get_main_queue();

        if (_timer) [self _reschedule];
    }
    [_lock unlock];
}

- (dispatch_queue_t)targetQueue {
    dispatch_queue_t queue = nil;
    [_lock lock];
    
    queue = _targetQueue;
    
    [_lock unlock];
    return queue;
}

- (id)target {
    id target = 0;
    [_lock lock];
    
    target = _target;
    
    [_lock unlock];
    return target;
}

- (SEL)action {
    SEL action = 0;
    [_lock lock];
    
    action = _action;
    
    [_lock unlock];
    return action;
}

- (id)userInfo {
    id userInfo = 0;
    [_lock lock];
    
    userInfo = _userInfo;
    
    [_lock unlock];
    return userInfo;
}

- (void (^)(GCDTimer *timer))block {
    void (^block)(GCDTimer *timer) = nil;
    [_lock lock];
    
    block = _block;
    
    [_lock unlock];
    return block;
}

#pragma mark - public

- (void)schedule {
    [_lock lock];
    [self _schedule];
    [_lock unlock];
}

- (void)fire {
    [_lock lock];
    [self _fire];
    [_lock unlock];
}

- (void)invalidate {
    [_lock lock];
    [self _invalidate];
    [_lock unlock];
}

#pragma mark - private

- (void)_schedule {
    if (_timer) dispatch_source_cancel(_timer);
    if (_interval < 0) return;
    if (!_valid) return;

    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _targetQueue);

    dispatch_time_t interval = _interval * NSEC_PER_SEC;
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, interval), interval, _leeway * NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self handleTimerEvent];
    });
    dispatch_resume(_timer);
}

- (void)_reschedule {
    [self _invalidate];

    _valid = YES;
    [self _schedule];
}

- (void)_fire {
    if ((!_target && !_block) || !_valid) return;

    [self _performAction];
}

- (void)_invalidate {
    if (_timer) dispatch_source_cancel(_timer);

    _timer = nil;
    _valid = NO;
}

- (void)_performAction {
    if (_block) {
        _block(self);
    } else if (_target && _action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop
    };
}

#pragma mark - protected

- (void)handleTimerEvent {
    [_lock lock];

    if ((!_target && !_block) || !_repeats || !_valid) [self _invalidate];

    [self _performAction];

    [_lock unlock];
}

@end
