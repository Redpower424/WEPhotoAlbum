//
//  AlbumListTableView.m
//  Created by Redpower on 2018/5/2.
//  Copyright © 2018年 We. All rights reserved.
//

#import "AlbumListTableView.h"
#import "AlbumListTableViewCell.h"
#import "WEAlbumHandler.h"
#import "WEDefine.h"

static NSString *identifier = @"AlbumListCellIdentifier";
@interface AlbumListTableView()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation AlbumListTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.delegate = self;
        self.dataSource = self;
        
        [self registerNib:[UINib nibWithNibName:@"AlbumListTableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
    }
    return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _albumListDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlbumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WEPhotoAlbumListModel *listModel = _albumListDataArray[indexPath.row];
    CGSize size = cell.albumImageView.size;
    [[WEAlbumHandler shareInstance] requestImageWithAsset:listModel.headAsset size:CGSizeMake(size.width * 2.5, size.height * 2.5) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
        [cell reloadWithImage:image title:listModel.title count:listModel.count];
    }];
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.albumDelegate && [self.albumDelegate respondsToSelector:@selector(albumListTableView:didSelectAlbumAtIndexPath:)]) {
        [self.albumDelegate albumListTableView:self didSelectAlbumAtIndexPath:indexPath];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (void)setAlbumListDataArray:(NSArray *)albumListDataArray{
    _albumListDataArray = albumListDataArray;
    [self reloadData];
}

@end
