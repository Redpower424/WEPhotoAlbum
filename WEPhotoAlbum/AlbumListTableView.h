//
//  AlbumListTableView.h
//  Created by Redpower on 2018/5/2.
//  Copyright © 2018年 We. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumListTableView;
@protocol AlbumListTableViewDelegate<NSObject>

//选择了相册
- (void)albumListTableView:(AlbumListTableView *)tableView didSelectAlbumAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface AlbumListTableView : UITableView

@property (nonatomic, strong) NSArray *albumListDataArray;

@property (nonatomic, weak) id<AlbumListTableViewDelegate> albumDelegate;

@end
