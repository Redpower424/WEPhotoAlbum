//
//  MBProgressHUD+WEExtension.h
//  Created by Redpower on 2018/5/8.
//  Copyright © 2018年 We. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (WEExtension)

+ (void)showText:(NSString *)text toView:(UIView *)view;

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;



@end
