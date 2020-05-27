//
//  GCDTimer+Private.h
//  Modool
//
//  Created by xulinfeng on 2018/4/24.
//  Copyright © 2018年 Modool. All rights reserved.
//

#import "GCDTimer.h"

@interface GCDTimer ()

- (void)_fire;
- (void)_schedule;
- (void)_reschedule;
- (void)_invalidate;
- (void)_performAction;

#pragma mark - protected

- (void)handleTimerEvent;

@end
