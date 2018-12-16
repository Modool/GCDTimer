//
//  GCDTimer.h
//  Bilibili
//
//  Created by xulinfeng on 2018/4/24.
//  Copyright © 2018年 markejave. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCDTimer : NSObject

// Maximum leeway seconds, default is 0.f;
@property (assign) NSTimeInterval leeway;

@property (assign, readonly) NSTimeInterval interval;
@property (assign, readonly) BOOL repeats;
@property (assign, readonly, getter=isValid) BOOL valid;

// Default is main queue.
@property (strong, nullable) dispatch_queue_t targetQueue;

@property (weak, nullable, readonly) id target;
@property (assign, nullable, readonly) SEL action;

@property (weak, readonly, nullable) id userInfo;

@property (copy, nullable, readonly) void (^block)(GCDTimer *timer);

+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats;
+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDTimer *timer))block;

+ (instancetype)timerWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats;
- (instancetype)initWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats NS_DESIGNATED_INITIALIZER;

+ (instancetype)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDTimer *timer))block;
- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GCDTimer *timer))block NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)schedule;

- (void)fire;
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
