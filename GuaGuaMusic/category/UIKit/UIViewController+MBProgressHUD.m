//
//  UIViewController+MBProgressHUD.m
//  GuaGuaMusic
//
//  Created by xxb on 15/12/28.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import "UIViewController+MBProgressHUD.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>

static const void *hudKey;

@implementation UIViewController (MBProgressHUD)

-(void)showHud{
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    hud.labelText = @"加载中";
    [self.view addSubview:hud];
    [hud show:YES];
    objc_setAssociatedObject(self, &hudKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)hideHud{
    MBProgressHUD *hud = objc_getAssociatedObject(self, &hudKey);
    [hud hide:YES];
}

-(void)showErrorHud:(NSString*)errorInfo{
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = errorInfo;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [self.view addSubview:hud];
    [hud hide:YES afterDelay:2];
}

@end
