//
//  WEBigImageViewController.h
//  Created by Redpower on 2018/5/4.
//  Copyright © 2018年 We. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^WEBigImageBlock)(NSMutableArray *selectedAssets, BOOL original, BOOL complete);

@interface WEBigImageViewController : UIViewController

- (instancetype)initWithAssets:(NSArray *)assets selectIndex:(NSInteger)selectIndex selectedAssets:(NSMutableArray *)selectedAssets original:(BOOL)original maxCount:(NSInteger)maxCount;

@property (nonatomic, copy) WEBigImageBlock bigImageBlock;

@end
