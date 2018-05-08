//
//  WESelectedImageModel.h
//  Created by Redpower on 2018/5/7.
//  Copyright © 2018年 We. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset;
@interface WESelectedImageModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *localIdentifier;

@end
