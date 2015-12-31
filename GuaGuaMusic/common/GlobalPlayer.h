//
//  GlobalPlayer.h
//  GuaGuaMusic
//
//  Created by xxb on 15/12/25.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKAudioPlayer.h"
#import "SongModel.h"

@interface GlobalPlayer : NSObject

@property (nonatomic, strong) STKAudioPlayer *audioPlayer;
@property (nonatomic, strong) SongModel *currentSong;

+(GlobalPlayer*)player;


+(void)stop;
+(void)pause;
+(void)resume;
+(void)play:(NSString*)songLink;
+(void)seekToTime:(double)time;

+(double)duration;
+(double)progress;


@end
