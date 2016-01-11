//
//  ALPhotoBrowserView.h
//  AnjuLife
//
//  Created by guohongwei719 on 15/12/30.
//  Copyright (c) 2015年 anjuke inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ALPhotoBrowserView;

@protocol ALPhotoBrowserViewDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(ALPhotoBrowserView *)browser placeholderImageForIndex:(NSInteger)index;

@optional

- (NSURL *)photoBrowser:(ALPhotoBrowserView *)browser highQualityImageURLForIndex:(NSInteger)index;
- (CGRect)getImageViewSourceFrameWithBrowserView:(ALPhotoBrowserView *)photoBrowserView;
@end


@interface ALPhotoBrowserView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;

@property (nonatomic, weak) id<ALPhotoBrowserViewDelegate> delegate;

- (void)show;

@end
