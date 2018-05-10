//
//  WEDefine.h
//  Created by Redpower on 2018/5/2.
//  Copyright © 2018年 We. All rights reserved.
//

#ifndef WEDefine_h
#define WEDefine_h

#import "UIView+WEExtension.h"
#import "WEDeviceModel.h"

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
#define KStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height       //状态栏高度
#define KNaviHeightWithoutStatusBar 44                                                      //导航栏除去状态栏的高度
#define KNaviHeight KStatusBarHeight + KNaviHeightWithoutStatusBar                          //导航栏高度

#define IS_iPhone4S [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 4S "]
#define IS_iPhone5 [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 5 "]
#define IS_iPhoneSE [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone SE "]
#define IS_iPhone6 [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 6 "]
#define IS_iPhone6S [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 6s "]
#define IS_iPhone6Plus [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 6Plus"]
#define IS_iPhone6sPlus [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 6sPlus"]
#define IS_iPhone7 [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 7 "]
#define IS_iPhone7Plus [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 7 Plus "]
#define IS_iPhone8 [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 8 "]
#define IS_iPhone8Plus [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone 8 Plus"]
#define IS_iPhoneX [[WEDeviceModel GetCurrentDeviceModel] containsString:@"iPhone X"]

#ifdef IS_iPhoneX
#define KTabbarHeight 83        //底栏高度
#else
#define
#define KTabbarHeight 49
#endif

#define IMAGEWITHBUNDLE_NAME(name) [UIImage imageNamed:[NSString stringWithFormat:@"WEPhotoAlbumBundle.bundle/%@", name]]

#define BlueColor [UIColor colorWithRed:0.1 green:0.4 blue:0.7 alpha:1]

static inline CABasicAnimation *buttonStatusChangeBasicAnimation() {
    //1.创建动画对象
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //2.设置动画属性
    basic.fromValue = @1.1;
    basic.toValue = @0.6;
    basic.duration = .15f;
    //恢复到原始状态时有动画效果,默认为NO
    basic.autoreverses = YES;
    //设置动画结束后不回复到原始状态
    basic.repeatCount = 1;
    basic.removedOnCompletion = YES;
    basic.fillMode = kCAFillModeForwards;
    basic.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return basic;
}


static inline CAKeyframeAnimation *buttonStatusChangeKeyframeAnimation() {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3f;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7f, 0.7f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8f, 0.8f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)]];
    
    return animation;
}


#endif /* WEDefine_h */
