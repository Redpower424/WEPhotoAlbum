//
//  WEThumbnailViewController.m
//  Created by Redpower on 2018/4/27.
//  Copyright © 2018年 We. All rights reserved.
//
//  缩略图视图

#import "WEThumbnailViewController.h"
#import "WEAlbumHandler.h"
#import "ThumbnailCollectionViewCell.h"
#import "AlbumListTableView.h"
#import "WEDefine.h"
#import "WEBigImageViewController.h"
#import "WESelectedImageModel.h"
#import "MBProgressHUD+WEExtension.h"

static NSString *identifier = @"ThumbnailCellIdentifier";
@interface WEThumbnailViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, AlbumListTableViewDelegate, ThumbnailCollectionViewCellDelegate>

@property (nonatomic, copy) NSString *assetCollectionTitle;         //相册名称
@property (nonatomic, assign) NSInteger maxSelectCount;             //最大选择数
@property (nonatomic, strong) PHAssetCollection *assetCollection;   //相册

@property (nonatomic, strong) UIView *naviView;                     //导航栏
@property (nonatomic, strong) UIButton *titleButton;                //标题按钮
@property (nonatomic, strong) UIView *bottomView;                   //底栏
@property (nonatomic, strong) UIButton *completeButton;             //完成按钮
@property (nonatomic, strong) UIButton *previewButton;              //预览按钮
@property (nonatomic, strong) UIButton *originalButton;             //原图按钮

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) AlbumListTableView *albumListTableView;          //相册列表
@property (nonatomic, strong) UIView *maskView;                                //蒙板
@property (nonatomic, strong) NSArray<PHAsset *> *allAssets;                   //相册中所有的asset

@property (nonatomic, strong) NSMutableArray *selectAssetArray;                //选中的照片
@property (nonatomic, assign) BOOL isOriginalPhoto;                            //是否选择原图

@end

@implementation WEThumbnailViewController

#pragma mark - life cycle
- (instancetype)initWithTitle:(NSString *)title maxSelectCount:(NSInteger)maxSelectCount assetCollection:(PHAssetCollection *)assetCollection{
    self = [super init];
    if (self) {
        _assetCollectionTitle = title;
        _maxSelectCount = maxSelectCount;
        _assetCollection = assetCollection;
        _selectAssetArray = [NSMutableArray array];
        _isOriginalPhoto = NO;      //默认非原图
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadPhotos];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.naviView];
    [self.view addSubview:self.bottomView];
    
    //collectionView默认滑到最底部,升序排列
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_allAssets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
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
    return UIStatusBarStyleLightContent;
}

#pragma mark - delegate
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _allAssets.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ThumbnailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    PHAsset *asset = _allAssets[indexPath.row];
    CGSize size = CGSizeMake(cell.frame.size.width * 2.5, cell.frame.size.height * 2.5);    //要控制好大小，会影响图片加载速度
    __weak typeof(self) weakSelf = self;
    [[WEAlbumHandler shareInstance] requestImageWithAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
        BOOL selected = NO;
        for (WESelectedImageModel *selectModel in weakSelf.selectAssetArray) {
            if ([asset.localIdentifier isEqualToString:selectModel.localIdentifier]) {
                selected = YES;
                break;
            }
        }
        [cell reloadWithImage:image selectState:selected];
    }];
    
    return cell;
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath item : %li",(long)indexPath.row);
    WEBigImageViewController *bigImageVC = [[WEBigImageViewController alloc] initWithAssets:_allAssets selectIndex:indexPath.row selectedAssets:_selectAssetArray original:_isOriginalPhoto maxCount:_maxSelectCount];
    bigImageVC.modalPresentationStyle = UIModalPresentationPopover;
    __weak typeof(self) weakSelf = self;
    bigImageVC.bigImageBlock = ^(NSMutableArray *selectedAssets, BOOL original, BOOL complete) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.selectAssetArray = selectedAssets;
        strongSelf.isOriginalPhoto = original;
        if (complete) {
            [strongSelf handleSelectedPhoto];
        }else{
            [strongSelf resetButtonsState];
            [strongSelf.collectionView reloadData];
        }
    };
    [self.navigationController pushViewController:bigImageVC animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (ScreenWidth - 5)/4.0;
    return CGSizeMake(width, width);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f);
}

#pragma mark - ThumbnailCollectionViewCellDelegate 图片选中按钮
- (void)thumbnailCollectionViewCell:(ThumbnailCollectionViewCell *)cell didSelect:(BOOL)selected{
    if (_selectAssetArray.count >= _maxSelectCount && selected == NO) {
        NSLog(@"最多选择10张图片");
        NSString *message = [NSString stringWithFormat:@"最多选择%li张照片",_maxSelectCount];
        [MBProgressHUD showText:message toView:nil];
        return;
    }
    
    cell.selectButton.selected = !cell.selectButton.selected;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    PHAsset *asset = _allAssets[indexPath.row];
    WESelectedImageModel *model = [[WESelectedImageModel alloc] init];
    model.asset = asset;
    model.localIdentifier = asset.localIdentifier;        //用于遍历判断是否已选择某一张图片
    
    if (cell.selectButton.selected) {
        [_selectAssetArray addObject:model];        //加入已选数组
        [cell.selectButton.layer addAnimation:buttonStatusChangeKeyframeAnimation() forKey:@""];        //添加动画
    }else{
        for (WESelectedImageModel *selectModel in _selectAssetArray) {
            if ([selectModel.localIdentifier isEqualToString:model.localIdentifier]) {
                //移除选中
                [_selectAssetArray removeObject:selectModel];
                break;
            }
        }
    }
    [self resetButtonsState];
}

#pragma mark - AlbumListTableViewDelegate
- (void)albumListTableView:(AlbumListTableView *)tableView didSelectAlbumAtIndexPath:(NSIndexPath *)indexPath{
    WEPhotoAlbumListModel *listModel = [[WEAlbumHandler shareInstance] getAllPhotoAlbumList][indexPath.row];
    _assetCollection = listModel.assetCollection;
    
    [_titleButton setTitle:listModel.title forState:UIControlStateNormal];
    [_titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_titleButton.imageView.width, 0, _titleButton.imageView.width)];
    [_titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, _titleButton.titleLabel.width, 0, -_titleButton.titleLabel.width)];
    
    [self loadPhotos];
    
    [self.collectionView reloadData];
    //collectionView默认滑到最底部,升序排列
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_allAssets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    [self hideAlbumList];
    _titleButton.selected = !_titleButton.selected;
}


#pragma mark - private method
- (void)loadPhotos{
    _allAssets = [[WEAlbumHandler shareInstance] getAssetsFromAssetCollection:_assetCollection ascending:YES];
}
//展开相册列表
- (void)showAlbumList{
    if (!_maskView) {
        [self.view addSubview:self.maskView];
    }
    if (!_albumListTableView) {
        [self.view addSubview:self.albumListTableView];
    }
    self.maskView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.albumListTableView.frame = CGRectMake(0, 64, ScreenWidth, 5 * 70);
        self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }];
}
//收起相册列表
- (void)hideAlbumList{
    [UIView animateWithDuration:0.3 animations:^{
        self.albumListTableView.frame = CGRectMake(0, 64, ScreenWidth, 0);
        self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {
        self.maskView.hidden = YES;
    }];
}
//计算原图字节大小
- (void)caculateOriginalByte{
    if (_isOriginalPhoto) {
        //计算原图大小
        __weak typeof(self) weakSelf = self;
        [[WEAlbumHandler shareInstance] caculatePhotoBytesWithAssets:_selectAssetArray completeBlock:^(NSString *byteString) {
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
//处理回调的图片,asset转为UIimage并压缩
- (void)handleSelectedPhoto{
    __weak typeof(self) weakSelf = self;
    NSMutableArray *images = [_selectAssetArray mutableCopy];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    for (int index = 0; index < images.count; index++) {
        WESelectedImageModel *model = images[index];
        [[WEAlbumHandler shareInstance] requestImageWithAsset:model.asset original:_isOriginalPhoto resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            [images replaceObjectAtIndex:index withObject:image];
            
            if (index == images.count - 1) {
                if (weakSelf.assetCompleteBlock) {
                    weakSelf.assetCompleteBlock(images);
                }
                [hud hideAnimated:YES];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}
//处理各个按钮的状态(原图按钮、预览按钮、确定按钮)
- (void)resetButtonsState{
    //是否已有选中图片
    if (_selectAssetArray.count > 0) {
        _originalButton.enabled = YES;
        _previewButton.enabled = YES;
        _completeButton.enabled = YES;
        [_completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_originalButton setTitleColor:BlueColor forState:UIControlStateNormal];        //原图按钮蓝色
        _originalButton.selected = _isOriginalPhoto;
    }else{
        _originalButton.enabled = NO;
        _previewButton.enabled = NO;
        _completeButton.enabled = NO;
        [_completeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];     //原图按钮灰色
    }
    [self caculateOriginalByte];
}

#pragma mark - event response
- (void)titleButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        [self showAlbumList];
    }else{
        [self hideAlbumList];
    }
}
- (void)cancelButtonAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)completeButtonAction{
    //回传图片前，判断是否需要原图，若不需要则压缩图片回传
    [self handleSelectedPhoto];
}
- (void)previewButtonAction{
    NSMutableArray *previewAssets = [NSMutableArray array];
    for (int index = 0; index < _selectAssetArray.count; index++) {
        WESelectedImageModel *model = _selectAssetArray[index];
        [previewAssets addObject:model.asset];
    }
    WEBigImageViewController *bigImageVC = [[WEBigImageViewController alloc] initWithAssets:previewAssets selectIndex:0 selectedAssets:_selectAssetArray original:_isOriginalPhoto maxCount:_maxSelectCount];
    bigImageVC.modalPresentationStyle = UIModalPresentationPopover;
    __weak typeof(self) weakSelf = self;
    bigImageVC.bigImageBlock = ^(NSMutableArray *selectedAssets, BOOL original, BOOL complete) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.selectAssetArray = selectedAssets;
        strongSelf.isOriginalPhoto = original;
        if (complete) {
            [strongSelf handleSelectedPhoto];
        }else{
            [strongSelf resetButtonsState];
            [strongSelf.collectionView reloadData];
        }
    };
    [self.navigationController pushViewController:bigImageVC animated:YES];
}
- (void)originalButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    _isOriginalPhoto = button.selected;
    [self caculateOriginalByte];
}
- (void)maskTapAction{
    [self hideAlbumList];
    _titleButton.selected = !_titleButton.selected;
}


#pragma mark - setter/getter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 1.0f;
        flowLayout.minimumInteritemSpacing = 1.0f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64 - 50) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"ThumbnailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    }
    return _collectionView;
}
- (AlbumListTableView *)albumListTableView{
    if (!_albumListTableView) {
        _albumListTableView = [[AlbumListTableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 0) style:UITableViewStylePlain];
        _albumListTableView.albumDelegate = self;
        _albumListTableView.albumListDataArray = [[WEAlbumHandler shareInstance] getAllPhotoAlbumList];
    }
    return _albumListTableView;
}
- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _maskView.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskTapAction)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}
- (UIView *)naviView{
    if (!_naviView) {
        _naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
        _naviView.backgroundColor = BlueColor;

        //标题
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.frame = CGRectMake((_naviView.frame.size.width - 150)/2.0, 20, 150, 44);
        UIImage *openImage = IMAGEWITHBUNDLE_NAME(@"btn_title_open");
        UIImage *closeImage = IMAGEWITHBUNDLE_NAME(@"btn_title_close");
        [_titleButton setImage:openImage forState:UIControlStateNormal];
        [_titleButton setImage:closeImage forState:UIControlStateSelected];
        [_titleButton setTitle:_assetCollectionTitle forState:UIControlStateNormal];
        [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _titleButton.titleLabel.numberOfLines = 2;
        [_titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_titleButton.imageView.width, 0, _titleButton.imageView.width)];
        [_titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, _titleButton.titleLabel.width, 0, -_titleButton.titleLabel.width)];
        [_titleButton addTarget:self action:@selector(titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_naviView addSubview:_titleButton];
        
        //取消
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 20, 60, 44);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_naviView addSubview:cancelButton];
        
        //确定按钮
        _completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeButton.frame = CGRectMake(_naviView.frame.size.width - 60, 20 + (44 - 35)/2.0, 60, 35);
        _completeButton.layer.cornerRadius = 5.0f;
        _completeButton.layer.masksToBounds = YES;
        _completeButton.backgroundColor = BlueColor;
        _completeButton.enabled = NO;
        [_completeButton setTitle:@"确定" forState:UIControlStateNormal];
        [_completeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _completeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_completeButton addTarget:self action:@selector(completeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_naviView addSubview:_completeButton];
        
    }
    return _naviView;
}
- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 50, ScreenWidth, 50)];
        _bottomView.backgroundColor = [UIColor whiteColor];

        //预览按钮
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.enabled = NO;
        _previewButton.frame = CGRectMake(15, 0, 0, 0);
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        _previewButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_previewButton sizeToFit];
        _previewButton.height = _bottomView.height;
        [_previewButton setTitleColor:BlueColor forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_previewButton addTarget:self action:@selector(previewButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_previewButton];
        
        //原图按钮
        _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalButton.enabled = NO;
        _originalButton.frame = CGRectMake(CGRectGetMaxX(_previewButton.frame) + 15, 0, 0, 0);
        [_originalButton setImage:IMAGEWITHBUNDLE_NAME(@"btn_original_circle") forState:UIControlStateNormal];
        [_originalButton setImage:IMAGEWITHBUNDLE_NAME(@"btn_selected") forState:UIControlStateSelected];
        [_originalButton setTitle:@" 原图" forState:UIControlStateNormal];
        _originalButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_originalButton sizeToFit];
        _originalButton.height = _bottomView.height;
        [_originalButton setTitleColor:BlueColor forState:UIControlStateNormal];
        [_originalButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_originalButton addTarget:self action:@selector(originalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_originalButton];
    }
    return _bottomView;
}





@end
