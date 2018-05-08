//
//  ViewController.m
//  PhotoAlbumDemo
//
//  Created by Redpower on 2018/4/10.
//  Copyright © 2018年 We. All rights reserved.
//

#import "ViewController.h"
#import "WEPhotoAlbum.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 100)/2.0, 50, 100, 100)];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.view addSubview:_imageView];
    
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame = CGRectMake(0, ScreenHeight/2.0 - 25, ScreenWidth, 50);
    [imageButton setTitle:@"选择相片" forState:UIControlStateNormal];
    [imageButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    imageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageButton.layer.cornerRadius = 5.0f;
    imageButton.layer.masksToBounds = YES;
    [imageButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageButton];
    
    UIButton *multipleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    multipleButton.frame = CGRectMake(0, ScreenHeight/2.0 + 25, ScreenWidth, 50);
    [multipleButton setTitle:@"多选相片" forState:UIControlStateNormal];
    [multipleButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    multipleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    multipleButton.layer.cornerRadius = 5.0f;
    multipleButton.layer.masksToBounds = YES;
    [multipleButton addTarget:self action:@selector(multipleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:multipleButton];
    
}

- (void)selectPhoto:(UIButton *)button{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __weak typeof(self) weakSelf = self;
        [[WEPhotoHelper shareInstance] presentPhotoPicker:WEPhotoSourceTypeCamera photoClipType:WEPhotoClipTypeNone targetVC:self completeBlock:^(UIImage *image, BOOL isCancel) {
            if (isCancel) {
                NSLog(@"取消了选择");
            }else{
                CGFloat scale = image.size.height / image.size.width;
                weakSelf.imageView.frame = CGRectMake((ScreenWidth - 200)/2.0, 50, 200, 200 * scale);
                weakSelf.imageView.image = image;
            }
        }];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从手机相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __weak typeof(self) weakSelf = self;
        [[WEPhotoHelper shareInstance] presentPhotoPicker:WEPhotoSourceTypeAlbum photoClipType:WEPhotoClipTypeNone targetVC:self completeBlock:^(UIImage *image, BOOL isCancel) {
            if (isCancel) {
                NSLog(@"取消了选择");
            }else{
                CGFloat scale = image.size.height / image.size.width;
                weakSelf.imageView.frame = CGRectMake((ScreenWidth - 200)/2.0, 50, 200, 200 * scale);
                weakSelf.imageView.image = image;
            }
        }];
    }];
    UIAlertAction *cameraClipAction = [UIAlertAction actionWithTitle:@"拍照(剪裁)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __weak typeof(self) weakSelf = self;
        [[WEPhotoHelper shareInstance] presentPhotoPicker:WEPhotoSourceTypeCamera photoClipType:WEPhotoClipTypeDefault targetVC:self completeBlock:^(UIImage *image, BOOL isCancel) {
            if (isCancel) {
                NSLog(@"取消了选择");
            }else{
                CGFloat scale = image.size.height / image.size.width;
                weakSelf.imageView.frame = CGRectMake((ScreenWidth - 200)/2.0, 50, 200, 200 * scale);
                weakSelf.imageView.image = image;
            }
        }];
    }];
    UIAlertAction *albumClipAction = [UIAlertAction actionWithTitle:@"从手机相册中选择(剪裁)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __weak typeof(self) weakSelf = self;
        [[WEPhotoHelper shareInstance] presentPhotoPicker:WEPhotoSourceTypeAlbum photoClipType:WEPhotoClipTypeDefault targetVC:self completeBlock:^(UIImage *image, BOOL isCancel) {
            if (isCancel) {
                NSLog(@"取消了选择");
            }else{
                CGFloat scale = image.size.height / image.size.width;
                weakSelf.imageView.frame = CGRectMake((ScreenWidth - 200)/2.0, 50, 200, 200 * scale);
                weakSelf.imageView.image = image;
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[WEAlbumHandler shareInstance] getAllPhotoAlbumList];
    }];
    [alertVC addAction:cameraAction];
    [alertVC addAction:cameraClipAction];
    [alertVC addAction:albumAction];
    [alertVC addAction:albumClipAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}


//多选
- (void)multipleButtonAction{
    NSArray *albums = [[WEAlbumHandler shareInstance] getAllPhotoAlbumList];
    WEPhotoAlbumListModel *albumListModel = albums[0];
    WEThumbnailViewController *thumbnailVC = [[WEThumbnailViewController alloc] initWithTitle:albumListModel.title maxSelectCount:10 assetCollection:albumListModel.assetCollection];
    __weak typeof(self) weakSelf = self;
    thumbnailVC.assetCompleteBlock = ^(NSArray *images) {
        NSLog(@"images : %@",images);
        if (images.count > 0) {
            weakSelf.imageView.image = images[0];
        }
    };
    UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:thumbnailVC];
    [self presentViewController:naviVC animated:YES completion:nil];
}


@end
