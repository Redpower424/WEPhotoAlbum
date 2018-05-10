//
//  WEBigImageViewController.m
//  Created by Redpower on 2018/5/4.
//  Copyright © 2018年 We. All rights reserved.
//

#import "WEBigImageViewController.h"
#import "WEDefine.h"
#import "BigImageCollectionViewCell.h"
#import "WESelectedImageModel.h"
#import <Photos/Photos.h>
#import "WEAlbumHandler.h"
#import "MBProgressHUD+WEExtension.h"

static NSString *identifier = @"BigImageCollectionViewCellIdentifier";
@interface WEBigImageViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, BigImageCollectionViewCellDelegate>

@property (nonatomic, assign) BOOL naviHidden;                      //导航栏是否隐藏

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *naviView;                     //导航栏
@property (nonatomic, strong) UILabel *titleLabel;                  //标题
@property (nonatomic, strong) UIView *bottomView;                   //底栏
@property (nonatomic, strong) UIButton *originalButton;             //原图
@property (nonatomic, strong) UIButton *selectButton;               //选择
@property (nonatomic, strong) UIButton *completeButton;             //完成

@property (nonatomic, strong) NSArray *assets;                      //所有图片
@property (nonatomic, assign) NSInteger selectIndex;                //当前的索引
@property (nonatomic, strong) NSMutableArray *selectedAssets;       //选择了的图片
@property (nonatomic, assign) NSInteger maxCount;                   //最大选择数
@property (nonatomic, assign) BOOL original;                        //是否原图

@end

@implementation WEBigImageViewController

#pragma mark - life cycle
- (instancetype)initWithAssets:(NSArray *)assets selectIndex:(NSInteger)selectIndex selectedAssets:(NSMutableArray *)selectedAssets original:(BOOL)original maxCount:(NSInteger)maxCount{
    self = [super init];
    if (self) {
        _assets = assets;
        _selectIndex = selectIndex;
        _selectedAssets = selectedAssets;
        _maxCount = maxCount;
        _original = original;
        _naviHidden = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.bottomView];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark - delegate
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _assets.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BigImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.asset = _assets[indexPath.row];
    
    return cell;
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = KScreenWidth;
    CGFloat height = collectionView.height;
    return CGSizeMake(width, height);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
}
#pragma mark - UIscrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        CGFloat index = scrollView.contentOffset.x/scrollView.width;
        _selectIndex = [[NSString stringWithFormat:@"%.0lf",index] integerValue];
        _titleLabel.text = [NSString stringWithFormat:@"%li/%li",_selectIndex + 1, _assets.count];
        PHAsset *asset = _assets[_selectIndex];
        BOOL selected = NO;
        for (WESelectedImageModel *selectModel in _selectedAssets) {
            if ([asset.localIdentifier isEqualToString:selectModel.localIdentifier]) {
                selected = YES;
                break;
            }
        }
        _selectButton.selected = selected ? YES:NO;
        _originalButton.enabled = _selectedAssets.count == 0 ? NO:YES;
    }
}

#pragma mark - BigImageCollectionViewCellDelegate   单击图片
- (void)bigImageCollectionViewCellDidSingleTap:(BigImageCollectionViewCell *)cell{
    _naviHidden = !_naviHidden;
    if (_naviHidden) {
        [UIView animateWithDuration:0.3 animations:^{
            self.naviView.alpha = 0;
            self.bottomView.alpha = 0;
            self.collectionView.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            self.naviView.hidden = YES;
            self.bottomView.hidden = YES;
        }];
    }else{
        self.naviView.hidden = NO;
        self.bottomView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.naviView.alpha = 1;
            self.bottomView.alpha = 1;
            self.collectionView.backgroundColor = [UIColor whiteColor];
        }];
    }
}


#pragma mark - private method
//计算原图字节大小
- (void)caculateOriginalByte{
    if (_original) {
        //计算原图大小
        __weak typeof(self) weakSelf = self;
        [[WEAlbumHandler shareInstance] caculatePhotoBytesWithAssets:_selectedAssets completeBlock:^(NSString *byteString) {
            NSString *titleString = @"";
            if (byteString.length == 0) {
                titleString = @" 原图";
            }else{
                titleString = [NSString stringWithFormat:@" 原图（%@）",byteString];
            }
            [weakSelf.originalButton setTitle:titleString forState:UIControlStateNormal];
            [weakSelf.originalButton sizeToFit];
            weakSelf.originalButton.height = weakSelf.bottomView.height;
        }];
    }else{
        [_originalButton setTitle:@" 原图" forState:UIControlStateNormal];
        [_originalButton sizeToFit];
        _originalButton.height = _bottomView.height;
    }
}


#pragma mark - event response
//原图
- (void)originalButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    _original = button.selected;
    [self caculateOriginalByte];
}
//确定
- (void)completeButtonAction{
    //回传_selectedAssets和_original
    if (self.bigImageBlock) {
        self.bigImageBlock(_selectedAssets, _original, YES);
    }
}
//选择
- (void)selectButtonAction:(UIButton *)button{
    if (_selectedAssets.count >= _maxCount && button.selected == NO) {
        NSString *text = [NSString stringWithFormat:@"最多选择%li张照片",_maxCount];
        [MBProgressHUD showText:text toView:self.view];
        return;
    }
    button.selected = !button.selected;
    PHAsset *asset = _assets[_selectIndex];
    WESelectedImageModel *model = [[WESelectedImageModel alloc] init];
    model.asset = asset;
    model.localIdentifier = asset.localIdentifier;
    BOOL selected = NO;
    for (WESelectedImageModel *selectModel in _selectedAssets) {
        if ([asset.localIdentifier isEqualToString:selectModel.localIdentifier]) {
            selected = YES;
            [_selectedAssets removeObject:selectModel];
            break;
        }
    }
    if (!selected) {
        [_selectedAssets addObject:model];
    }
    //确定按钮
    NSString *completeTitle = _selectedAssets.count > 0 ? [NSString stringWithFormat:@"确定(%li)",_selectedAssets.count]:@"确定";
    [_completeButton setTitle:completeTitle forState:UIControlStateNormal];
    UIColor *color = _selectedAssets.count == 0 ? [UIColor lightGrayColor]:BlueColor;
    [_completeButton setBackgroundColor:color];
    _completeButton.enabled = _selectedAssets.count == 0 ? NO:YES;
    //原图按钮状态
    _originalButton.enabled = _selectedAssets.count > 0 ? YES:NO;
    [_originalButton setTitleColor:color forState:UIControlStateNormal];
    [self caculateOriginalByte];
}
//返回
- (void)backButtonAction{
    //回传_selectedAssets和_original
    if (self.bigImageBlock) {
        self.bigImageBlock(_selectedAssets, _original, NO);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - setter/getter
//导航栏
- (UIView *)naviView{
    if (!_naviView) {
        _naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KNaviHeight)];
        _naviView.backgroundColor = [UIColor whiteColor];
        
        //返回按钮
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, KStatusBarHeight, 60, 44);
        [backButton setImage:IMAGEWITHBUNDLE_NAME(@"btn_back") forState:UIControlStateNormal];
        CGSize size = IMAGEWITHBUNDLE_NAME(@"btn_back").size;
        [backButton setImageEdgeInsets:UIEdgeInsetsMake((backButton.height - size.height)/2.0,15, (backButton.height - size.height)/2.0, backButton.width - 15 - size.width)];
        [backButton setImageEdgeInsets:UIEdgeInsetsMake(12, 15, 12, 25)];
        [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_naviView addSubview:backButton];
        
        //标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_naviView.width - 150)/2.0, KStatusBarHeight, 150, 44)];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = [NSString stringWithFormat:@"%li/%li",_selectIndex + 1, _assets.count];
        [_naviView addSubview:_titleLabel];
        
        //选择按钮
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.frame = CGRectMake(_naviView.width - 60 - 10, KStatusBarHeight, 60, 44);
        [_selectButton setImage:IMAGEWITHBUNDLE_NAME(@"btn_unselected") forState:UIControlStateNormal];
        [_selectButton setImage:IMAGEWITHBUNDLE_NAME(@"btn_selected") forState:UIControlStateSelected];
        size = IMAGEWITHBUNDLE_NAME(@"btn_selected").size;
        [_selectButton setImageEdgeInsets:UIEdgeInsetsMake((_selectButton.height - size.height)/2.0, _selectButton.width - size.width, (_selectButton.height - size.height)/2.0, 0)];
        [_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_naviView addSubview:_selectButton];
        PHAsset *asset = _assets[_selectIndex];
        BOOL selected = NO;
        for (WESelectedImageModel *selectModel in _selectedAssets) {
            if ([asset.localIdentifier isEqualToString:selectModel.localIdentifier]) {
                selected = YES;
                break;
            }
        }
        _selectButton.selected = selected ? YES:NO;
    }
    return _naviView;
}
//底栏
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - KTabbarHeight, KScreenWidth, KTabbarHeight)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        //原图按钮
        _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalButton.selected = _original;
        _originalButton.enabled = _selectedAssets.count == 0 ? NO:YES;
        _originalButton.frame = CGRectMake(15, 0, 0, 0);
        [_originalButton setImage:IMAGEWITHBUNDLE_NAME(@"btn_original_circle") forState:UIControlStateNormal];
        [_originalButton setImage:IMAGEWITHBUNDLE_NAME(@"btn_selected") forState:UIControlStateSelected];
        [_originalButton setTitle:@" 原图" forState:UIControlStateNormal];
        _originalButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_originalButton sizeToFit];
        _originalButton.height = _bottomView.height;
        UIColor *color = _selectedAssets.count == 0 ? [UIColor lightGrayColor]:BlueColor;
        [_originalButton setTitleColor:color forState:UIControlStateNormal];
        [_originalButton addTarget:self action:@selector(originalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_originalButton];
        [self caculateOriginalByte];
        
        //确定按钮
        _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeButton.frame = CGRectMake(_bottomView.width - 70 - 10, (_bottomView.height - 35)/2.0, 70, 35);
        _completeButton.layer.cornerRadius = 5.0f;
        _completeButton.layer.masksToBounds = YES;
        NSString *completeTitle = _selectedAssets.count > 0? [NSString stringWithFormat:@"确定(%li)",_selectedAssets.count]:@"确定";
        [_completeButton setTitle:completeTitle forState:UIControlStateNormal];
        [_completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_completeButton setBackgroundColor:color];
        _completeButton.enabled = _selectedAssets.count == 0 ? NO:YES;
        _completeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_completeButton addTarget:self action:@selector(completeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_completeButton];
    }
    return _bottomView;
}
//collectionView
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 10.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-5, 0, KScreenWidth + 10, KScreenHeight) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[BigImageCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    }
    return _collectionView;
}



@end
