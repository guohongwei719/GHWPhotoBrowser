//
//  ALSinglePhotoView.h
//  AnjuLife
//
//  Created by guohongwei719 on 15/12/30.
//  Copyright (c) 2015年 anjuke inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALSinglePhotoView : UIView
@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,strong) UIImageView *imageview;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL hasLoadedImage;
@property (nonatomic, assign) BOOL beginLoadingImage;
//@property (nonatomic, assign) BOOL beginLoadingImage;
//单击回调
@property (nonatomic, strong) void (^singleTapBlock)(UITapGestureRecognizer *recognizer);
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)setImage:(UIImage *)image;
@end
