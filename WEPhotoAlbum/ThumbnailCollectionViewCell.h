//
//  ThumbnailCollectionViewCell.h
//  Created by Redpower on 2018/4/27.
//  Copyright © 2018年 We. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThumbnailCollectionViewCell;
@protocol ThumbnailCollectionViewCellDelegate<NSObject>

- (void)thumbnailCollectionViewCell:(ThumbnailCollectionViewCell *)cell didSelect:(BOOL)selected;

@end

@interface ThumbnailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

- (void)reloadWithImage:(UIImage *)image selectState:(BOOL)selectState;

@property (nonatomic, weak) id<ThumbnailCollectionViewCellDelegate> delegate;

@end
