//
//  AlbumListTableViewCell.h
//  Created by Redpower on 2018/5/2.
//  Copyright © 2018年 We. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

- (void)reloadWithImage:(UIImage *)image title:(NSString *)title count:(NSInteger) count;

@end
