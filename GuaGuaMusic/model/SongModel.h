//
//  SongModel.h
//  GuaGuaMusic
//
//  Created by xxb on 15/12/28.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongModel : NSObject

@property(nonatomic, strong) NSString *songId;
@property(nonatomic, strong) NSString *songLink;
@property(nonatomic, strong) NSString *songLrcLink;
@property(nonatomic, strong) NSMutableArray *songTimeArray;
@property(nonatomic, strong) NSMutableArray *songLrcArray;

@end
