//
//  WEDefine.h
//  Created by Redpower on 2018/5/2.
//  Copyright © 2018年 We. All rights reserved.
//

#ifndef WEDefine_h
#define WEDefine_h

#import "UIView+WEExtension.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

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
