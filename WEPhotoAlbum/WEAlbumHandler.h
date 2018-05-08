//
//  WEAlbumHandler.h
//  Created by Redpower on 2018/4/11.
//  Copyright © 2018年 We. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface WEPhotoAlbumListModel : NSObject

@property (nonatomic, copy) NSString *title;                            //相册标题
@property (nonatomic, assign) NSInteger count;                          //相册中相片的数量
@property (nonatomic, strong) PHAsset *headAsset;                       //相册中的第一张图片缩略图
@property (nonatomic, strong) PHAssetCollection *assetCollection;       //相册。通过该属性获取该相册下的所有相片

@end

@interface WEAlbumHandler : NSObject

//单例对象
+ (instancetype)shareInstance;

//拿到所有相册列表
- (NSArray<WEPhotoAlbumListModel *> *)getAllPhotoAlbumList;

//拿到相册中所有照片
- (NSArray<PHAsset *> *)getAllAssetsFromAlbumWithAscending:(BOOL)ascending;

//获取制定相册内照片
- (NSArray<PHAsset *> *)getAssetsFromAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;

//获取asset对应的照片UIImage
- (void)requestImageWithAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeModel completion:(void(^)(UIImage *image, NSDictionary *info))completion;

//根据asset获取对应的照片UIimge，返回原图或压缩图
- (void)requestImageWithAsset:(PHAsset *)asset original:(BOOL)original resizeMode:(PHImageRequestOptionsResizeMode)resizeModel completion:(void(^)(UIImage *image))completion;

//计算图片字节大小
- (void)caculatePhotoBytesWithAssets:(NSArray *)assets completeBlock:(void(^)(NSString *byteString))completeBlock;

@end

