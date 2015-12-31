//
//  UIViewController+MBProgressHUD.h
//  GuaGuaMusic
//
//  Created by xxb on 15/12/28.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UIViewController (MBProgressHUD)

//手动关闭
-(void)showHud;
-(void)hideHud;

-(void)showErrorHud:(NSString*)errorInfo;

@end
