//
//  WEPhotoHelper.m
//  Created by Redpower on 2018/4/10.
//  Copyright © 2018年 We. All rights reserved.
//

#import "WEPhotoHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface WEPhotoHelper()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerVC;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, copy) PhotoCompleteBlock completeBlock;
@property (nonatomic, assign) WEPhotoClipType photoClipType;

@end

@implementation WEPhotoHelper

/** 单例
 *
 */
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static WEPhotoHelper *photoHelper = nil;
    dispatch_once(&onceToken, ^{
        photoHelper = [[WEPhotoHelper alloc] init];
    });
    return photoHelper;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        if (!_imagePickerVC) {
            _imagePickerVC = [[UIImagePickerController alloc] init];
        }
    }
    return self;
}


- (void)presentPhotoPicker:(WEPhotoSourceType)photoSourceType photoClipType:(WEPhotoClipType)photoClipType targetVC:(UIViewController *)viewController completeBlock:(PhotoCompleteBlock)completeBlock{
    _viewController = viewController;
    _completeBlock = completeBlock;
    _photoClipType = photoClipType;
    
    if (photoSourceType == WEPhotoSourceTypeAlbum) {        //从相册选取
        if ([self isAlbumAvailable]) {      //检查是否有相册权限
            _imagePickerVC.delegate = self;
            _imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if (photoClipType == WEPhotoClipTypeNone) {
                _imagePickerVC.allowsEditing = NO;
            }else{
                _imagePickerVC.allowsEditing = YES;
            }
            [viewController presentViewController:_imagePickerVC animated:YES completion:nil];
        }else{
            [self showAlertControllerWithTitle:@"请在iPhone的“设置-隐私-照片”选项中，允许本应用访问你的手机相册"];
        }
        
    }else if (photoSourceType == WEPhotoSourceTypeCamera){  //从相机拍摄
        if ([self isCameraAvailable]) {     //检查是否有相机权限
            _imagePickerVC.delegate = self;
            _imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            if (photoClipType == WEPhotoClipTypeNone) {
                _imagePickerVC.allowsEditing = NO;
            }else{
                _imagePickerVC.allowsEditing = YES;
            }
            [viewController presentViewController:_imagePickerVC animated:YES completion:nil];
        }else{
            [self showAlertControllerWithTitle:@"请在iPhone的“设置-隐私-相机”选项中，允许本应用访问你的手机相机"];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
//取消选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        self.completeBlock(nil, YES);
    }];
}
//选择完成
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        //是否需要剪裁
        if (self.photoClipType == WEPhotoClipTypeNone) {    //不需要剪裁
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            self.completeBlock(image, NO);
        }else if (self.photoClipType == WEPhotoClipTypeDefault){    //需要剪裁
            //可以在这里自定义相片剪裁
            UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
            self.completeBlock(image, NO);
        }
    }];
}




#pragma mark - private method
//提示
- (void)showAlertControllerWithTitle:(NSString *)title{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:nil];
    [alertVC addAction:action];
    [_viewController presentViewController:alertVC animated:YES completion:nil];
}

//检查是否有摄像头权限
- (BOOL)isCameraAvailable{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied || ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return NO;
    }
    return YES;
}

//检查是否有相册权限
- (BOOL)isAlbumAvailable{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted || ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return NO;
    }
    return YES;
}
















@end
