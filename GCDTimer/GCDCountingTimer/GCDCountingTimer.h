//
//  GCDCountingTimer.h
//  Modool
//
//  Created by xulinfeng on 2018/4/24.
//  Copyright © 2018年 Modool. All rights reserved.
//
#import <GCDTimer/GCDTimer.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    double begin;
    double end;
} GCDCountingRange;

@interface GCDCountingTimer : GCDTimer

/// Default is NSRangeZero
@property (assign) GCDCountingRange range;

/// Default is 0.f.
@property (assign, readonly) double current;

/// Default is 1.
@property (assign) double offset;

/// Default is nil.
@property (copy) double (^offsetBlock)(GCDCountingTimer *timer);

@property (copy, nullable, readonly) void (^block)(GCDCountingTimer *timer);

+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats NS_UNAVAILABLE;
+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDTimer *timer))block NS_UNAVAILABLE;

+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval range:(GCDCountingRange)range offset:(double)offset target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats;
+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval range:(GCDCountingRange)range offset:(double)offset repeats:(BOOL)repeats block:(void (^)(GCDCountingTimer *timer))block;

+ (instancetype)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDCountingTimer *timer))block;
- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDCountingTimer *timer))block;

@end

NS_ASSUME_NONNULL_END
