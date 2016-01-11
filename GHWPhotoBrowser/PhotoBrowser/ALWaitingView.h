//
//  ALWaitingView.h
//  AnjuLife
//
//  Created by guohongwei719 on 15/12/30.
//  Copyright (c) 2015年 anjuke inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kWaitingViewModeLoopDiagram, // 环形
    kWaitingViewModePieDiagram // 饼型
} ALWaitingViewMode;

@interface ALWaitingView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) int mode;

@end
