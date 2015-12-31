//
//  GlobalPlayer.m
//  GuaGuaMusic
//
//  Created by xxb on 15/12/25.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import "GlobalPlayer.h"

@interface GlobalPlayer()<STKAudioPlayerDelegate>{
    
}

@end

@implementation GlobalPlayer

+(GlobalPlayer*)player{
    static GlobalPlayer *globalPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalPlayer = [[self alloc] init];
    });
    return globalPlayer;
}

-(id)init{
    self = [super init];
    if(self){
        _audioPlayer = [[STKAudioPlayer alloc] init];
        _audioPlayer.delegate = self;
        _currentSong = [[SongModel alloc] init];
    }
    return self;
}

+(void)stop{
    [[self player].audioPlayer stop];
}

+(void)pause{
    [[self player].audioPlayer pause];
}
+(void)resume{
    [[self player].audioPlayer resume];
}
+(void)play:(NSString*)songLink{
    [[self player].audioPlayer play:songLink];
}
+(void)seekToTime:(double)time{
    [[self player].audioPlayer seekToTime:time];
}

+(double)duration{
    return [self player].audioPlayer.duration;
}
+(double)progress{
    return [self player].audioPlayer.progress;
}
+(STKAudioPlayerState)state{
    return [self player].audioPlayer.state;
}

#pragma mark STKAudioPlayerDelegate

-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId{}
/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId{}
/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState{}
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{
    [_audioPlayer stop];
    [_audioPlayer seekToTime:0.0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playFinish" object:nil];
}

@end
