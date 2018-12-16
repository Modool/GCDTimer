//
//  GCDTimer+Private.h
//  BBLiveBase
//
//  Created by xulinfeng on 2018/7/30.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "GCDTimer.h"

@interface GCDTimer () {
@protected
    NSRecursiveLock *_lock;

    dispatch_source_t _timer;
    dispatch_queue_t _targetQueue;

    NSTimeInterval _leeway;
    NSTimeInterval _interval;

    BOOL _repeats;
    BOOL _valid;
    SEL _action;
    __weak id _target;
    __weak id _userInfo;

    void (^_block)(GCDTimer *timer);
}

- (void)_fire;
- (void)_schedule;
- (void)_reschedule;
- (void)_invalidate;
- (void)_performAction;

#pragma mark - protected

- (void)handleTimerEvent;

@end
