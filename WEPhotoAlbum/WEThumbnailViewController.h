//
//  WEThumbnailViewController.h
//  Created by Redpower on 2018/4/27.
//  Copyright © 2018年 We. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAssetCollection;
typedef void(^WEAssetsCompleteBlock)(NSArray *images);
@interface WEThumbnailViewController : UIViewController

- (instancetype)initWithTitle:(NSString *)title maxSelectCount:(NSInteger)maxSelectCount assetCollection:(PHAssetCollection *)assetCollection;

@property (nonatomic, copy) WEAssetsCompleteBlock assetCompleteBlock;

@end
