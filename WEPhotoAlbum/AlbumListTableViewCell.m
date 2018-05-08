//
//  AlbumListTableViewCell.m
//  Created by Redpower on 2018/5/2.
//  Copyright © 2018年 We. All rights reserved.
//

#import "AlbumListTableViewCell.h"

@interface AlbumListTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumCountLabel;


@end

@implementation AlbumListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)reloadWithImage:(UIImage *)image title:(NSString *)title count:(NSInteger)count{
    _albumImageView.image = image;
    _albumTitleLabel.text = title;
    _albumCountLabel.text = [NSString stringWithFormat:@"%li",count];
}

@end
