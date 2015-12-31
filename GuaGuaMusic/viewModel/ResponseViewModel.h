//
//  ResponseViewModel.h
//  GuaGuaMusic
//
//  Created by xxb on 15/12/29.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseViewModel : NSObject

@property(assign, nonatomic) BOOL success;
@property(strong, nonatomic) NSString *errorInfo;
@property(strong, nonatomic) id responseData;

@end
