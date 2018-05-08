//
//  WEPhotoHelper.h
//  Created by Redpower on 2018/4/10.
//  Copyright © 2018年 We. All rights reserved.
//
/** 单选相片
 *  选取图片有两种方式：1、相册  2、相机
 *  常用的图片处理 1、裁剪  2、不裁剪
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*选取图片的途径（相册、相机）*/
typedef NS_ENUM(NSInteger, WEPhotoSourceType){
    WEPhotoSourceTypeCamera = 0,     //相机
    WEPhotoSourceTypeAlbum       //相册
};

/**图片是否需要裁剪处理*/
typedef NS_ENUM(NSInteger, WEPhotoClipType){
    WEPhotoClipTypeDefault = 0,          //裁剪
    WEPhotoClipTypeNone            //不裁剪
};

/**图片选取完成回调
 @prama image   选择的相片
 @prama iscancel    是否取消选择
 */
typedef void(^PhotoCompleteBlock)(UIImage *image, BOOL isCancel);

@interface WEPhotoHelper : NSObject

/*单例对象*/
+ (instancetype)shareInstance;

/** 选取图片
 @prama photoSourceType     相片来源
 @prama photoClipType       剪裁类型
 @prama viewController      控制器对象，即调用者
 @prama completeBlock       数据回调
 */
- (void)presentPhotoPicker:(WEPhotoSourceType)photoSourceType photoClipType:(WEPhotoClipType)photoClipType targetVC:(UIViewController *)viewController completeBlock:(PhotoCompleteBlock)completeBlock;

@end
