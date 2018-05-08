//
//  ThumbnailCollectionViewCell.m
//  Created by Redpower on 2018/4/27.
//  Copyright © 2018年 We. All rights reserved.
//

#import "ThumbnailCollectionViewCell.h"

@interface ThumbnailCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;


@end

@implementation ThumbnailCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)reloadWithImage:(UIImage *)image selectState:(BOOL)selectState{
    _thumbnailImageView.image = image;
    _selectButton.selected = selectState;
}
- (IBAction)selectButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(thumbnailCollectionViewCell:didSelect:)]) {
        [self.delegate thumbnailCollectionViewCell:self didSelect:sender.selected];
    }
}



@end
