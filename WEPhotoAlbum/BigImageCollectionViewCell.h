//
//  BigImageCollectionViewCell.h
//  Created by Redpower on 2018/5/4.
//  Copyright © 2018年 We. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BigImageCollectionViewCell;
@protocol BigImageCollectionViewCellDelegate<NSObject>

- (void)bigImageCollectionViewCellDidSingleTap:(BigImageCollectionViewCell *)cell;

@end

@class PHAsset;
@interface BigImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, weak) id<BigImageCollectionViewCellDelegate> delegate;

@end
