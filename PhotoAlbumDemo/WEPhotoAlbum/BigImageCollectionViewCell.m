//
//  BigImageCollectionViewCell.m
//  Created by Redpower on 2018/5/4.
//  Copyright © 2018年 We. All rights reserved.
//

#import "BigImageCollectionViewCell.h"
#import "WEAlbumHandler.h"
#import "WEDefine.h"

@interface BigImageCollectionViewCell()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation BigImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
    }
    return self;
}

#pragma mark - UIScrollvViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //调整imageview的center
    CGFloat offsetX = scrollView.width > scrollView.contentSize.width ? (scrollView.width - scrollView.contentSize.width)/2.0 : 0.0;
    CGFloat offsetY = scrollView.height > scrollView.contentSize.height ? (scrollView.height - scrollView.contentSize.height)/2.0 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return scrollView.subviews[0];
}

#pragma mark - response event
//单击
- (void)singleTapAction:(UITapGestureRecognizer *)gesture{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bigImageCollectionViewCellDidSingleTap:)]) {
        [self.delegate bigImageCollectionViewCellDidSingleTap:self];
    }
}
//双击
- (void)doubleTapAction:(UITapGestureRecognizer *)gesture{
    UIScrollView *scrollView = (UIScrollView *)gesture.view;
    CGFloat scale = 1.0;
    if (scrollView.zoomScale != 3) {
        //放大
        scale = 3.0;
    }else{
        //缩小
        scale = 1.0;
    }
    //将更小范围的rect放到scrollView的frame上看即会有放大效果
    CGFloat zoomHeight = scrollView.height / scale;
    CGFloat zoomWidth = scrollView.width / scale;
    CGPoint center = [gesture locationInView:gesture.view];
    CGFloat zoomOriginX = center.x - zoomWidth/2.0;
    CGFloat zoomOriginY = center.y - zoomHeight/2.0;
    [scrollView zoomToRect:CGRectMake(zoomOriginX, zoomOriginY, zoomWidth, zoomHeight) animated:YES];
}

#pragma mark - getter
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        //单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        [_scrollView addGestureRecognizer:singleTap];
        //双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return _scrollView;
}
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (void)setAsset:(PHAsset *)asset{
    _asset = asset;
    CGFloat scale = [UIScreen mainScreen].scale;        //屏幕分辨率
    CGFloat width = KScreenWidth * scale;
    CGFloat height = width / (asset.pixelWidth/asset.pixelHeight);
    CGSize size = CGSizeMake(width, height);
    __weak typeof(self) weakSelf = self;
    [[WEAlbumHandler shareInstance] requestImageWithAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        weakSelf.imageView.image = image;
        //拿到图片后重新设置尺寸
        [weakSelf resetSubViewsRect];
    }];
}

#pragma mark - private method
- (void)resetSubViewsRect{
    CGSize imageSize = _imageView.image.size;
    CGFloat imageScale = imageSize.width / imageSize.height;
    CGFloat screenScale = KScreenWidth/ KScreenHeight;
    CGRect frame = CGRectZero;
    if (imageScale < screenScale) {
        //长图
        frame.size.height = self.height;
        frame.size.width = self.height * imageScale;
    }else{
        frame.size.width = self.width;
        frame.size.height = self.width / imageScale;
    }
    _scrollView.zoomScale = 1.0;
    _scrollView.contentSize = frame.size;
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _imageView.frame = frame;
    _imageView.center = _scrollView.center;
}


@end
