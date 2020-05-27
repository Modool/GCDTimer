//
//  GCDCountingTimer.m
//  Modool
//
//  Created by xulinfeng on 2018/7/30.
//  Copyright © 2018年 Modool. All rights reserved.
//

#import "GCDCountingTimer.h"

@interface GCDTimer ()

- (void)_invalidate;
- (void)_performAction;

@end

@interface GCDCountingTimer () {
    GCDCountingRange _range;
    double _current;
    double _offset;
    double (^_offsetBlock)(GCDCountingTimer *timer);
}

@end

@implementation GCDCountingTimer
@dynamic block;

+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval range:(GCDCountingRange)range offset:(double)offset target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats {
    GCDCountingTimer *timer = [self timerWithInterval:interval target:target action:action userInfo:userInfo repeats:repeats];
    timer->_range = range;
    timer->_offset = offset;
    timer->_current = range.begin;

    [timer schedule];
    return timer;
}

+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval range:(GCDCountingRange)range offset:(double)offset repeats:(BOOL)repeats block:(void (^)(GCDCountingTimer *timer))block {
    GCDCountingTimer *timer = [self timerWithInterval:interval repeats:repeats block:block];
    timer->_range = range;
    timer->_offset = offset;
    timer->_current = range.begin;

    [timer schedule];
    return timer;
}

+ (instancetype)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDCountingTimer *timer))block {
    return [[self alloc] initWithInterval:interval repeats:repeats block:block];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDCountingTimer *timer))block {
    void (^transformer)(GCDTimer *timer) = ^(GCDTimer *timer) {
        if (block) block((GCDCountingTimer *)timer);
    };
    return [super initWithInterval:interval repeats:repeats block:transformer];
}

#pragma mark - accessor

- (GCDCountingRange)range {
    GCDCountingRange range;

    [_lock lock];
    range = _range;
    [_lock unlock];

    return range;
}

- (void)setRange:(GCDCountingRange)range {
    [_lock lock];
    _range = range;
    _current = range.begin;
    [_lock unlock];
}

- (double)current {
    double current;

    [_lock lock];
    current = _current;
    [_lock unlock];

    return current;
}

- (double)offset {
    double offset;

    [_lock lock];
    offset = _offset;
    [_lock unlock];

    return offset;
}

- (void)setOffset:(double)offset {
    [_lock lock];
    _offset = offset;
    [_lock unlock];
}

- (void)setOffsetBlock:(double (^)(GCDCountingTimer *))offsetBlock {
    [_lock lock];
    _offsetBlock = [offsetBlock copy];
    [_lock unlock];
}

- (double (^)(GCDCountingTimer *))offsetBlock {
    double (^offsetBlock)(GCDCountingTimer *) = nil;

    [_lock lock];
    offsetBlock = [_offsetBlock copy];
    [_lock unlock];

    return offsetBlock;
}

#pragma mark - protected

- (void)handleTimerEvent {
    [_lock lock];
    if ((!_target && !_block) || !_valid) {
        [self _invalidate];
    } else {
        _current += _offsetBlock ? _offsetBlock(self) : _offset;

        [self _performAction];

        double maximum = MAX(_range.begin, _range.end);
        double minimum = MIN(_range.begin, _range.end);
        if (_current >= maximum || _current <= minimum) {
            if (_repeats) {
                _current = _range.begin;
            } else {
                [self _invalidate];
            }
        }
    }
    [_lock unlock];
}

@end
