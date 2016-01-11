//
//  ALPhotoBrowserView.m
//  AnjuLife
//
//  Created by guohongwei719 on 15/12/30.
//  Copyright (c) 2015年 anjuke inc. All rights reserved.
//

#import "ALPhotoBrowserView.h"
#import "UIImageView+WebCache.h"
#import "ALSinglePhotoView.h"

static const CGFloat kPhotoBrowserAnimationDuration = 0.35f;
static const CGFloat kPhotoBrowserImageViewMargin = 10;                  // browser中图片间的margin
static const CGFloat ALPhotoBrowserShowImageAnimationDuration = 0.25f;    // browser中显示图片动画时长
static const CGFloat ALPhotoBrowserHideImageAnimationDuration = 0.25f;    // browser中隐藏图片动画时长
NSString * const kPhotoBrowserSaveImageSuccessText = @" 保存成功 ";  // 图片保存成功提示文字
NSString * const kPhotoBrowserSaveImageFailText = @" 保存失败 ";      // 图片保存失败提示文字

#define kPhotoBrowserBackgrounColor [UIColor colorWithRed:0 green:0 blue:0 alpha:1]    // browser背景颜色
#define kAPPWidth [UIScreen mainScreen].bounds.size.width
#define KAppHeight [UIScreen mainScreen].bounds.size.height

@interface ALPhotoBrowserView()

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UILabel *indexLabel;
@property (nonatomic,strong) UIButton *saveButton;
@property (nonatomic,strong) UIView *contentView;

@property (nonatomic, assign) BOOL hasShowedFistView;
@property (nonatomic, assign) BOOL shouldLandscape;

@end

@implementation ALPhotoBrowserView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shouldLandscape = YES;
        self.backgroundColor = kPhotoBrowserBackgrounColor;
    }
    return self;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return _indicatorView;
}

- (UILabel *)indexLabel
{
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
        _indexLabel.bounds = CGRectMake(0, 0, 80, 30);
        _indexLabel.center = CGPointMake(kAPPWidth * 0.5, 30);
        _indexLabel.layer.cornerRadius = 15;
        _indexLabel.clipsToBounds = YES;
    }
    return _indexLabel;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = kPhotoBrowserBackgrounColor;
    }
    return _contentView;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] init];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveButton.layer.borderWidth = 0.1;
        _saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
        _saveButton.layer.cornerRadius = 2;
        _saveButton.clipsToBounds = YES;
        [_saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

//当视图移动完成后调用
- (void)didMoveToSuperview
{
    [self setupScrollView];
    [self setupToolbars];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupToolbars
{
    // 1. 序标
    if (self.imageCount > 1) {
        self.indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
        [self addSubview:self.indexLabel];
    }
    // 2.保存按钮
    [self addSubview:self.saveButton];
}

#pragma mark 保存图像
- (void)saveImage
{
    int index = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    ALSinglePhotoView *currentView = self.scrollView.subviews[index];
    UIImageWriteToSavedPhotosAlbum(currentView.imageview.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    self.indicatorView.center = self.center;
    [[UIApplication sharedApplication].keyWindow addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [self.indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 40);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = kPhotoBrowserSaveImageFailText;
    }   else {
        label.text = kPhotoBrowserSaveImageSuccessText;
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)setupScrollView
{
    [self addSubview:self.scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        ALSinglePhotoView *view = [[ALSinglePhotoView alloc] init];
        view.imageview.tag = i;
        
        //处理单击
        __weak __typeof(self)weakSelf = self;
        view.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf photoClick:recognizer];
        };
        
        [self.scrollView addSubview:view];
    }
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    ALSinglePhotoView *view = self.scrollView.subviews[index];
    if (view.beginLoadingImage) return;
    if ([self highQualityImageURLForIndex:index]) {
        [view setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        [view setImage:[self placeholderImageForIndex:index]];
        view.hasLoadedImage = YES;
    }
    view.beginLoadingImage = YES;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    //    CGRect rect = [UIScreen mainScreen].bounds;
    rect.size.width += kPhotoBrowserImageViewMargin * 2;
    self.scrollView.bounds = rect;
    //    self.scrollView.center = self.center;
    self.scrollView.center = CGPointMake(self.bounds.size.width *0.5, self.bounds.size.height *0.5);
    
    CGFloat y = 0;
    __block CGFloat w = self.scrollView.frame.size.width - kPhotoBrowserImageViewMargin * 2;
    CGFloat h = self.scrollView.frame.size.height;
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(ALPhotoBrowserView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = kPhotoBrowserImageViewMargin + idx * (kPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.subviews.count * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.currentImageIndex * self.scrollView.frame.size.width, 0);
    
    
    if (!self.hasShowedFistView) {
        [self showFirstImage];
    }
    
    self.indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    self.indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 30);
    self.saveButton.frame = CGRectMake(30, self.bounds.size.height - 70, 55, 30);
    if ([self highQualityImageURLForIndex:self.currentImageIndex] == nil) {
        self.saveButton.hidden = YES;
    } else {
        self.saveButton.hidden = NO;
    }
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.contentView.center = window.center;
    self.contentView.bounds = window.bounds;
    self.center = CGPointMake(self.contentView.bounds.size.width * 0.5, self.contentView.bounds.size.height * 0.5);
    self.bounds = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    [self.contentView addSubview:self];
    window.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
    //[self performSelector:@selector(onDeviceOrientationChangeWithObserver) withObject:nil afterDelay:HZPhotoBrowserShowImageAnimationDuration + 0.2];
    
    [window addSubview:self.contentView];
    
    
}
- (void)onDeviceOrientationChangeWithObserver
{
    [self onDeviceOrientationChange];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)onDeviceOrientationChange
{
    if (!self.shouldLandscape) {
        return;
    }
    ALSinglePhotoView *currentView = self.scrollView.subviews[self.currentImageIndex];
    [currentView.scrollview setZoomScale:1.0 animated:YES];//还原
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        //        NSLog(@"onDeviceOrientationChange");
        [UIView animateWithDuration:kPhotoBrowserAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
            self.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(M_PI*1.5):CGAffineTransformMakeRotation(M_PI/2);
            self.bounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:nil];
    }else if (orientation==UIDeviceOrientationPortrait){
        [UIView animateWithDuration:kPhotoBrowserAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
            self.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
            self.bounds = screenBounds;
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:nil];
    }
}

- (void)showFirstImage
{
//    UIView *sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
//
//    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    CGRect rect = [self getImageSourceFrame];

    NSLog(@"%@",NSStringFromCGRect(rect));

    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.frame = rect;
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    [self addSubview:tempView];
    tempView.contentMode = UIViewContentModeScaleAspectFit;


    CGFloat placeImageSizeW = tempView.image.size.width;
    CGFloat placeImageSizeH = tempView.image.size.height;
    CGRect targetTemp;

    CGFloat placeHolderH = (placeImageSizeH * kAPPWidth)/placeImageSizeW;
    if (placeHolderH <= KAppHeight) {
        targetTemp = CGRectMake(0, (KAppHeight - placeHolderH) * 0.5 , kAPPWidth, placeHolderH);
    } else {//图片高度>屏幕高度
        targetTemp = CGRectMake(0, 0, kAPPWidth, placeHolderH);
    }

    //先隐藏scrollview
    self.scrollView.hidden = YES;
    self.indexLabel.hidden = YES;
    self.saveButton.hidden = YES;

    [UIView animateWithDuration:ALPhotoBrowserShowImageAnimationDuration animations:^{
        //将点击的临时imageview动画放大到和目标imageview一样大
        tempView.frame = targetTemp;
    } completion:^(BOOL finished) {
        //动画完成后，删除临时imageview，让目标imageview显示
        self.hasShowedFistView = YES;
        [tempView removeFromSuperview];
        self.scrollView.hidden = NO;
        self.indexLabel.hidden = NO;
        _saveButton.hidden = NO;
    }];
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

- (CGRect)getImageSourceFrame
{
    if ([self.delegate respondsToSelector:@selector(getImageViewSourceFrameWithBrowserView:)]) {
        return [self.delegate getImageViewSourceFrameWithBrowserView:self];
    }
    return CGRectMake(0, 0, kAPPWidth, KAppHeight);
}

#pragma mark - scrollview代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + self.scrollView.bounds.size.width * 0.5) / self.scrollView.bounds.size.width;
    //    int imageIndex = (scrollView.contentOffset.x + self.scrollView.bounds.size.width * 0.9) / self.scrollView.bounds.size.width;
    //    if (imageIndex >= self.imageCount - 1) {
    //        imageIndex = (int)self.imageCount - 1;
    //    }
    //    if (imageIndex <= 0) {
    //        imageIndex= 0;
    //    }
    self.indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    //    NSLog(@"%i",imageIndex);
    long left = index - 1;
    long right = index + 1;
    left = left>0?left : 0;
    right = right>self.imageCount?self.imageCount:right;
    
    for (long i = left; i < right; i++) {
        [self setupImageOfImageViewForIndex:i];
    }
    
    //    [self setupImageOfImageViewForIndex:imageIndex];
}

//scrollview结束滚动调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int autualIndex = scrollView.contentOffset.x  / self.scrollView.bounds.size.width;
    //设置当前下标
    self.currentImageIndex = autualIndex;
    //将不是当前imageview的缩放全部还原 (这个方法有些冗余，后期可以改进)
    for (ALSinglePhotoView *view in self.scrollView.subviews) {
        if (view.imageview.tag != autualIndex) {
            view.scrollview.zoomScale = 1.0;
        } else {
            if ([self highQualityImageURLForIndex:(autualIndex - 1)] == nil) {
                self.saveButton.hidden = YES;
            } else {
                self.saveButton.hidden = NO;
            }
        }
    }
}

#pragma mark - tap
#pragma mark 双击
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    ALSinglePhotoView *view = (ALSinglePhotoView *)recognizer.view;
    CGPoint touchPoint = [recognizer locationInView:self];
    if (view.scrollview.zoomScale <= 1.0) {
        
        CGFloat scaleX = touchPoint.x + view.scrollview.contentOffset.x;//需要放大的图片的X点
        CGFloat sacleY = touchPoint.y + view.scrollview.contentOffset.y;//需要放大的图片的Y点
        [view.scrollview zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
        
    } else {
        [view.scrollview setZoomScale:1.0 animated:YES]; //还原
    }
    
}

#pragma mark 单击
- (void)photoClick:(UITapGestureRecognizer *)recognizer
{
    ALSinglePhotoView *currentView = self.scrollView.subviews[self.currentImageIndex];
    [currentView.scrollview setZoomScale:1.0 animated:YES];//还原
    self.indexLabel.hidden = YES;
    self.saveButton.hidden = YES;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)UIDeviceOrientationPortrait];
            self.transform = CGAffineTransformIdentity;
            self.bounds = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self hidePhotoBrowser:recognizer];
        }];
    } else {
        [self hidePhotoBrowser:recognizer];
    }
}

- (void)hidePhotoBrowser:(UITapGestureRecognizer *)recognizer
{
        ALSinglePhotoView *view = (ALSinglePhotoView *)recognizer.view;
        UIImageView *currentImageView = view.imageview;
    CGRect targetTemp = [self getImageSourceFrame];
    
        UIImageView *tempImageView = [[UIImageView alloc] init];
        tempImageView.image = currentImageView.image;
        CGFloat tempImageSizeH = tempImageView.image.size.height;
        CGFloat tempImageSizeW = tempImageView.image.size.width;
        CGFloat tempImageViewH = (tempImageSizeH * kAPPWidth)/tempImageSizeW;
    
        if (tempImageViewH < KAppHeight) {//图片高度<屏幕高度
            tempImageView.frame = CGRectMake(0, (KAppHeight - tempImageViewH)*0.5, kAPPWidth, tempImageViewH);
        } else {
            tempImageView.frame = CGRectMake(0, 0, kAPPWidth, tempImageViewH);
        }
        [self addSubview:tempImageView];
    
        self.saveButton.hidden = YES;
        self.indexLabel.hidden = YES;
        self.scrollView.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.window.windowLevel = UIWindowLevelNormal;//显示状态栏
        [UIView animateWithDuration:ALPhotoBrowserHideImageAnimationDuration animations:^{
            tempImageView.frame = targetTemp;
        } completion:^(BOOL finished) {
    [self.contentView removeFromSuperview];
            [tempImageView removeFromSuperview];
        }];
}

@end