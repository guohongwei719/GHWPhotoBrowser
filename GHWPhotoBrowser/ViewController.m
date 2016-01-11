//
//  ViewController.m
//  GHWPhotoBrowser
//
//  Created by guohongwei719 on 16/1/8.
//  Copyright © 2016年 ghw. All rights reserved.
//

#import "ViewController.h"
#import "ALPhotoBrowserView.h"
#import "UIImageView+WebCache.h"

@interface ViewController () <ALPhotoBrowserViewDelegate>

@property (nonatomic, strong) NSArray *srcStringArray;
@property (nonatomic, strong) UIImage *placeholderImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView1.clipsToBounds = YES;
    self.imageView2.clipsToBounds = YES;
    self.imageView3.clipsToBounds = YES;
    
    _srcStringArray = @[
                        @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
                        @"http://ww4.sinaimg.cn/thumbnail/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",
                        @"http://ww4.sinaimg.cn/thumbnail/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"
                        ];
    
    self.placeholderImage = [UIImage imageNamed:@"defaultImage"];
    
    [self.imageView1 sd_setImageWithURL:self.srcStringArray[0] placeholderImage:self.placeholderImage];
    [self.imageView2 sd_setImageWithURL:self.srcStringArray[1] placeholderImage:self.placeholderImage];
    [self.imageView3 sd_setImageWithURL:self.srcStringArray[2] placeholderImage:self.placeholderImage];
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView1 addGestureRecognizer:tapGesture1];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView2 addGestureRecognizer:tapGesture2];
    UITapGestureRecognizer *tapGesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView3 addGestureRecognizer:tapGesture3];
    
}

- (void)imageTapped:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.view == self.imageView1) {
        [self didClickOnImageIndex:0];
        NSLog(@"1");
    } else if (tapGesture.view == self.imageView2) {
        [self didClickOnImageIndex:1];
        NSLog(@"2");
    } else if (tapGesture.view == self.imageView3) {
        [self didClickOnImageIndex:2];
        NSLog(@"3");
    }
}

- (void)didClickOnImageIndex:(NSUInteger)index
{
    //启动图片浏览器
    ALPhotoBrowserView *browser = [[ALPhotoBrowserView alloc] init];
    browser.imageCount = self.srcStringArray.count; // 图片总数
    browser.currentImageIndex = index;
    browser.delegate = self;
    [browser show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - PhotoBrowser 代理方法

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(ALPhotoBrowserView *)browser placeholderImageForIndex:(NSInteger)index
{
    if (index == 0) {
        return self.imageView1.image;
    } else if (index == 1) {
        return self.imageView2.image;
    } else if (index == 2) {
        return self.imageView3.image;
    }
    return self.placeholderImage;
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(ALPhotoBrowserView *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *urlStr = [self.srcStringArray[index] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    return [NSURL URLWithString:urlStr];
}

- (CGRect)getImageViewSourceFrameWithBrowserView:(ALPhotoBrowserView *)photoBrowserView
{
    UIImageView *temImageView = nil;
    if (photoBrowserView.currentImageIndex == 0) {
        temImageView = self.imageView1;
    } else if (photoBrowserView.currentImageIndex == 1) {
        temImageView = self.imageView2;
    } else if (photoBrowserView.currentImageIndex == 2) {
        temImageView = self.imageView3;
    }
    CGRect rect = [temImageView convertRect:temImageView.bounds toView:self.view];
    return rect;
}

@end
