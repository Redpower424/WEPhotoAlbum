//
//  WEAlbumHandler.m
//  Created by Redpower on 2018/4/11.
//  Copyright © 2018年 We. All rights reserved.
//

#import "WEAlbumHandler.h"
#import "WESelectedImageModel.h"

@implementation WEPhotoAlbumListModel

@end

@implementation WEAlbumHandler

+ (instancetype)shareInstance{
    static WEAlbumHandler *albumHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        albumHandler = [[WEAlbumHandler alloc] init];
    });
    return albumHandler;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - 拿到所有相册列表
- (NSArray<WEPhotoAlbumListModel *> *)getAllPhotoAlbumList{
    NSMutableArray *photoAlbumArray = [NSMutableArray array];
    
    //1.获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //2.遍历智能相册,取出(除视频和最近删除外的)其中的图片
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *  _Nonnull assetCollection, NSUInteger idx, BOOL * _Nonnull stop) {
        //2.1过滤掉视频(202)和最近删除、livePhoto等(<212)
        if (assetCollection.assetCollectionSubtype != 202 && assetCollection.assetCollectionSubtype < 212) {
            NSArray *assets = [self getAssetsFromAssetCollection:assetCollection ascending:NO];
            if (assets.count > 0) {
                WEPhotoAlbumListModel *listModel = [[WEPhotoAlbumListModel alloc] init];
                listModel.title = assetCollection.localizedTitle;
                listModel.count = assets.count;
                listModel.headAsset = assets.firstObject;
                listModel.assetCollection = assetCollection;
                [photoAlbumArray addObject:listModel];
            }
        }
    }];
    
    //3.获取用户自己创建的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *  _Nonnull assetCollection, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *assets = [self getAssetsFromAssetCollection:assetCollection ascending:NO];
        if (assets.count > 0) {
            WEPhotoAlbumListModel *listModel = [[WEPhotoAlbumListModel alloc] init];
            listModel.title = assetCollection.localizedTitle;
            listModel.count = assets.count;
            listModel.headAsset = assets.firstObject;
            listModel.assetCollection = assetCollection;
            [photoAlbumArray addObject:listModel];
        }
    }];
    
    return photoAlbumArray;
}

#pragma mark - 获取相册内所有照片资源
- (NSArray<PHAsset *> *)getAllAssetsFromAlbumWithAscending:(BOOL)ascending{
    NSMutableArray *assets = [NSMutableArray array];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending];   //排序,YES为升序   creationDate是PHAsset的一条属性，相片生成时间
    options.sortDescriptors = @[sortDescriptor];
    
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    NSLog(@"fetchResult : %@",fetchResult);
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    return assets;
}

#pragma mark - 获取指定相册内照片
- (NSArray<PHAsset *> *)getAssetsFromAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending{
    NSMutableArray *assets = [NSMutableArray array];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending];
    options.sortDescriptors = @[sortDescriptor];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [assets addObject:obj];
        }
    }];
    return assets;
}

#pragma mark - 获取asset对应的照片UIImage
- (void)requestImageWithAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeModel completion:(void(^)(UIImage *image, NSDictionary *info))completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = resizeModel;//resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
    option.networkAccessAllowed = YES;
    
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downLoadFinished = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        if (downLoadFinished && completion) {
            completion(result, info);
        }
    }];
//    NSLog(@"requestionID : %i",requestID);
}

#pragma mark - 根据asset获取对应的照片UIimge，并压缩图片质量
- (void)requestImageWithAsset:(PHAsset *)asset original:(BOOL)original resizeMode:(PHImageRequestOptionsResizeMode)resizeModel completion:(void(^)(UIImage *image))completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = resizeModel;//resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
    option.networkAccessAllowed = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downLoadFinished = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downLoadFinished && completion) {
            
            NSData *jpegImageData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1);
            NSLog(@"原图大小：%.1lfKB",jpegImageData.length/1024.0);
            NSInteger maxLength = 100 * 1024;       //100KB
            UIImage *image = original?[UIImage imageWithData:jpegImageData]:[self compressImageWithImageData:jpegImageData maxLength:maxLength];     //压缩图片质量，最大100KB
            
            completion(image);
        }
    }];
}

//压缩图片质量至指定字节大小
- (UIImage *)compressImageWithImageData:(NSData *)imageData maxLength:(NSInteger)maxLength{
    CGFloat scale = 1;
    UIImage *image = [UIImage imageWithData:imageData];
    if (imageData.length <= maxLength) return image;

    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; i++) {       //这里指定压缩6次，避免耗时太长
        scale = (max + min)/2.0;
        imageData = UIImageJPEGRepresentation(image, scale);
        if (imageData.length < maxLength * 0.9) {
            min = scale;
        }else if (imageData.length > maxLength){
            max = scale;
        }else{
            break;
        }
    }
    //若此时已经压缩到期望大小，则返回image,
    image = [UIImage imageWithData:imageData];
    NSLog(@"压缩质量后：%.1lfKB",imageData.length/1024.0);
    if (imageData.length < maxLength) return image;
    
    //压缩图片尺寸
    NSUInteger lastImageDataLength = 0;
    while (imageData.length > maxLength && imageData.length != lastImageDataLength) {
        lastImageDataLength = imageData.length;
        CGFloat scale = (CGFloat)maxLength / imageData.length;
        CGSize size = CGSizeMake((NSInteger)image.size.width * sqrtf(scale), (NSInteger)image.size.height * sqrtf(scale));
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        imageData = UIImageJPEGRepresentation(image, 1);
    }
    image = [UIImage imageWithData:imageData];
    NSLog(@"压缩尺寸后：%.1lfKB",imageData.length/1024.0);
    
    return image;
}

#pragma mark - 计算图片字节大小
- (void)caculatePhotoBytesWithAssets:(NSArray *)assets completeBlock:(void (^)(NSString *))completeBlock{
    __block NSInteger totalLength = 0;
    if (!assets || assets.count == 0) {
        completeBlock(@"");
    }else{
        for (int index = 0; index < assets.count; index++) {
            WESelectedImageModel *model = assets[index];
            PHAsset *asset = model.asset;
            [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                totalLength = totalLength + imageData.length;
                if (index == assets.count - 1) {
                    NSString *dataLengthString = @"";
                    if (totalLength >= 1024 * 1024 * 0.1) {
                        dataLengthString = [NSString stringWithFormat:@"%.1lfM",totalLength/(1024.0 * 1024.0)];
                    }else if (totalLength >= 1024 * 0.1){
                        dataLengthString = [NSString stringWithFormat:@"%.1lfKB",totalLength/1024.0];
                    }else{
                        dataLengthString = [NSString stringWithFormat:@"%liB",totalLength];
                    }
                    completeBlock(dataLengthString);
                }
            }];
        }
    }
}


@end




















