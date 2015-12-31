//
//  MusicNetKit.h
//  demo-xxb
//
//  Created by xxb on 15/12/14.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseViewModel.h"

@interface MusicNetKit : NSObject

+(void)getSongInformationWith:(NSString*)songId completionHandler:(void (^) (ResponseViewModel *response)) completionHandler;

+(void)getSongLrcWith:(NSString*)url completionHandler:(void (^) (ResponseViewModel *response)) completionHandler;

+(void)searchWith:(NSString*)keyword completionHandler:(void (^) (NSString *lrcContent)) completionHandler;

+(void)getSongListBy:(NSString*)singerId completionHandler:(void (^) (ResponseViewModel *response)) completionHandler;

@end
