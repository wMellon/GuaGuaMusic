//
//  LrcRemoteViewController.m
//  demo-xxb
//
//  Created by xxb on 15/12/11.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import "LrcRemoteViewController.h"
#import "STKAudioPlayer.h"
//#import "FMSongModel.h"
#import "MusicNetKit.h"
#import "GlobalPlayer.h"

#define lineHeight 25

@interface LrcRemoteViewController (){
    BOOL isPause;
    int currentIndex;
    
    NSString *_songLink;
    NSString *_songLrcLink;
    NSMutableArray *_timeArray;
    NSMutableArray *_lrcArray;
    NSMutableArray *_lrcLabelArray;
}

//@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (strong, nonatomic) UIScrollView *lrcScrollView;
@property (strong, nonatomic) UIView *lrcView;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation LrcRemoteViewController

#pragma mark - init初始化

-(void)commonInit{
    
    isPause = YES;
    currentIndex = -1;
    
    //slider设置
    _slider.value = 0.0;
    
    _lrcScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 80, SCREEN_WIDTH - 40, 300)];
    //禁止手动拉动
    _lrcScrollView.userInteractionEnabled = NO;
    [self.view addSubview:_lrcScrollView];
    
    _lrcView = [[UIView alloc] init];
    _lrcView.clipsToBounds = YES;    //view超出scrollview隐藏
    [_lrcScrollView addSubview:_lrcView];
    [_lrcScrollView setContentOffset:CGPointMake(0, 0)];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
    
    _timeArray = [[NSMutableArray alloc] init];
    _lrcArray = [[NSMutableArray alloc] init];
    _lrcLabelArray = [[NSMutableArray alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish) name:@"playFinish" object:nil];
}

#pragma mark - view生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
    //当前在播放的是否是同一首歌
    if([[GlobalPlayer player].currentSong.songId isEqualToString:_songId]){
        //先停止计时
        [_timer setFireDate:[NSDate distantFuture]];
        //设置歌词滚动高度
        _timeArray = [GlobalPlayer player].currentSong.songTimeArray;
        _lrcArray = [GlobalPlayer player].currentSong.songLrcArray;
        [self setupLrcScrollView:[GlobalPlayer player].currentSong.songTimeArray and:[GlobalPlayer player].currentSong.songLrcArray];
        [self play:_playBtn];
    }else{
        //先停掉播放器
        [GlobalPlayer stop];
        [self loadSong:_songId completionHandler:^{
            //将音乐信息存到缓存
            [GlobalPlayer player].currentSong.songId = _songId;
            [GlobalPlayer player].currentSong.songLink = _songLink;
            
            [self loadLrc:_songLrcLink completionHandler:^(NSString* lrcContent){
                [self dealWithLrc:lrcContent];
                //处理完成后开始播放
                [self play:_playBtn];
            }];
        }];
    }
    
}

-(void)loadSong:(NSString*)songId completionHandler:(void (^) ()) completionHandler{
    [self showHud];
    [MusicNetKit getSongInformationWith:songId completionHandler:^(ResponseViewModel *response) {
        [self hideHud];
        if(response.success){
            NSDictionary *data = response.responseData;
            if(data && [[data allKeys] containsObject:@"data"]){
                NSDictionary *dict = data[@"data"];
                if(dict && [[dict allKeys] containsObject:@"songList"]){
                    NSDictionary *songDict = [dict[@"songList"] firstObject];
                    _songLink = songDict[@"songLink"];
                    NSRange range = [_songLink rangeOfString:@"src"];
                    if (range.location != 2147483647 && range.length != 0) {
                        NSString * temp = [_songLink substringToIndex:range.location-1];
                        _songLink = temp;
                    }
                    //获取歌词
                    _songLrcLink = [NSString stringWithFormat:@"http://music.baidu.com%@", songDict[@"lrcLink"]];
                    completionHandler();
                }
            }
        }else{
            [self showErrorHud:response.errorInfo];
        }
    }];
}

-(void)loadLrc:(NSString*)lrcLink completionHandler:(void (^) (NSString* lrcContent)) completionHandler{
    [self showHud];
    [MusicNetKit getSongLrcWith:_songLrcLink completionHandler:^(ResponseViewModel *response){
        [self hideHud];
        if(response.success){
            completionHandler(response.responseData);
        }else{
            [self showErrorHud:response.errorInfo];
        }
    }];
}

//处理歌词
-(void)dealWithLrc:(NSString*)lrcContent{
    NSArray *array = [lrcContent componentsSeparatedByString:@"\n"];
    NSMutableDictionary *lrcTimeDict = [[NSMutableDictionary alloc] init];
    for(NSString *content in array){
        //过滤前面
        if([NSString isBlankString:content] || content.length < 10){
            continue;
        }
        NSString *temp = [content substringToIndex:10];
        if(![temp hasPrefix:@"["] || ![temp hasSuffix:@"]"]){
            continue;
        }
        //al:恋人创世纪
        NSRange range = [temp rangeOfString:@"^\\[[0-6][0-9]:[0-6][0-9]\\.[0-9][0-9]\\]$" options:NSRegularExpressionSearch];
        if(range.location == NSNotFound){
            continue;
        }
        //正式切割
        //[02:06.53][00:38.24]你太善良 你太美丽
        NSArray *tempArray = [content componentsSeparatedByString:@"]"];
        for(int i = 0; i < tempArray.count - 1; i ++){
            temp = tempArray[i];
            if([temp hasPrefix:@"["]){
                [lrcTimeDict setObject:tempArray[tempArray.count - 1] forKey:[temp substringWithRange:NSMakeRange(1, temp.length - 1)]];
            }
        }
    }
    //排序
    NSArray *tempArray = [lrcTimeDict allKeys];
    _timeArray = [[tempArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *s1 = obj1;
        NSString *s2 = obj2;
        int i1 = [self getNumFromTimeStr:s1];
        int i2 = [self getNumFromTimeStr:s2];
        
        if (i1 > i2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (i1 < i2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }] mutableCopy];
    for(int i = 0; i < _timeArray.count; i++){
        [_lrcArray addObject: [lrcTimeDict valueForKey:_timeArray[i]]];
    }
    
    //将歌词内容、对应时间设置到缓存中
    [GlobalPlayer player].currentSong.songLrcArray = _lrcArray;
    [GlobalPlayer player].currentSong.songTimeArray = _timeArray;
    
    //设置歌词滚动高度
    [self setupLrcScrollView:_timeArray and:_lrcArray];
}

-(void)setupLrcScrollView:(NSMutableArray*)timeArray and:(NSMutableArray*)lrcArray{
    //设置歌词滚动高度
    _lrcView.frame = CGRectMake(0, 0, _lrcScrollView.width, timeArray.count * lineHeight + _lrcScrollView.height / 2);
    _lrcScrollView.contentSize = CGSizeMake(_lrcScrollView.width, _lrcView.height);
    for(int i = 0; i < timeArray.count; i++){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, i * lineHeight + _lrcScrollView.height / 2, _lrcScrollView.width, lineHeight)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = lrcArray[i];
        label.font = [UIFont systemFontOfSize:14.0];
        [_lrcView addSubview:label];
        [_lrcLabelArray addObject:label];
    }
}

-(int)getNumFromTimeStr:(NSString*)timeStr{
    if([NSString isBlankString:timeStr]){
        return 0;
    }
    NSArray *array = [timeStr componentsSeparatedByString:@":"];
    int result = [array[0] intValue] * 60 * 100 + [array[1] floatValue] * 100;
    return result;
}

-(void)playProgress{
    //进度条设置
    _slider.minimumValue = 0.0;
    _slider.maximumValue = GlobalPlayer.duration;
    _progressLabel.text = [self double2Str:GlobalPlayer.progress];
    _durationLabel.text = [self double2Str:GlobalPlayer.duration];
    [_slider setValue:GlobalPlayer.progress animated:YES];
    //歌词
//    int b = _audioPlayer.progress * 100;
//    for(int i = 0; i < _timeArray.count; i++){
//        NSString *time = _timeArray[i];
//        int a = [self getNumFromTimeStr:time];
//        if(a == b){
//            if(i != 0){
//                UILabel *label = _lrcLabelArray[i - 1];
//                label.textColor = [UIColor blackColor];
//            }
//            UILabel *label = _lrcLabelArray[i];
//            label.textColor = [UIColor redColor];
//            [_lrcScrollView setContentOffset:CGPointMake(0, i * lineHeight) animated:YES];
//            break;
//        }
//    }
    
    int x = GlobalPlayer.progress * 100;//＊100，lrc分割时时间的最小单位是0.01s
    if(_timeArray.count > 0 && _lrcLabelArray.count > 0){
        for(int i = 0; i < _timeArray.count - 1; i++){
            int a = [self getNumFromTimeStr:_timeArray[i]];
            int b = [self getNumFromTimeStr:_timeArray[i + 1]];
            //显示的歌词必须是在[a,b}之间
            if(x >= a && x < b){
                if(currentIndex == -1 || currentIndex != i){
                    //将之前突出的label重置
                    if(i != 0){
                        UILabel *label = _lrcLabelArray[i - 1];
                        label.textColor = [UIColor blackColor];
                    }
                    UILabel *label = _lrcLabelArray[i];
                    label.textColor = [UIColor redColor];
                    [_lrcScrollView setContentOffset:CGPointMake(0, i * lineHeight) animated:YES];
//                    _lrcView.top = _lrcView.top - lineHeight;
//                    NSLog(@"%f", _lrcView.top);
                    currentIndex = i;
                }
            }
        }
    }
}

//将时间转成00:00格式
-(NSString*)double2Str:(double)time{
    int temp = time;
    int m = temp / 60;
    int s = temp % 60;
    NSString *result = @"";
    if(m < 10){
        result = [result stringByAppendingString:[NSString stringWithFormat:@"0%d:", m]];
    }else{
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%d:", m]];
    }
    if(s < 10){
        result = [result stringByAppendingString:[NSString stringWithFormat:@"0%d", s]];
    }else{
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%d", s]];
    }
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)playFinish{
    [self resetLrcLabel];
    _progressLabel.text = @"00:00";
    
    [_timer setFireDate:[NSDate distantFuture]];
    isPause = YES;
    
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_slider setValue:0.0 animated:YES];
}

#pragma mark - action

- (IBAction)stop:(id)sender {
    [GlobalPlayer stop];
    [GlobalPlayer seekToTime:0.0];
    [self resetLrcLabel];
    [_timer setFireDate:[NSDate distantFuture]];
    isPause = YES;
    
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_slider setValue:0.0 animated:YES];
}

- (IBAction)play:(id)sender {
    isPause = !isPause;
    //状态为点击后的状态
    if(isPause){
        [_timer setFireDate:[NSDate distantFuture]];
        [GlobalPlayer pause];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        [_timer setFireDate:[NSDate date]];
        
        if([[GlobalPlayer player].audioPlayer currentlyPlayingQueueItemId]){
            [GlobalPlayer resume];
        }else{
            [GlobalPlayer play:_songLink];
        }
        
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

-(void)resetLrcLabel{
    for(UILabel *label in _lrcLabelArray){
        label.textColor = [UIColor blackColor];
    }
    [_lrcScrollView setContentOffset:CGPointMake(0, 0)];
}

- (IBAction)chgProgress:(id)sender {
    
//    [_audioPlayer seekToTime:_slider.value];
//    //歌词
//    int x = _slider.value * 100;
//    for(int i = 0; i < _timeArray.count - 1; i++){
//        int a = [self getNumFromTimeStr:_timeArray[i]];
//        int b = [self getNumFromTimeStr:_timeArray[i + 1]];\
//        if(x >= a && x <= b){
//            int temp = i;
//            if(x != b){
//                temp = i + 1;
//            }
//            if(temp != 0){
//                UILabel *label = _lrcLabelArray[temp - 1];
//                label.textColor = [UIColor blackColor];
//            }
//            UILabel *label = _lrcLabelArray[temp];
//            label.textColor = [UIColor redColor];
//            [_lrcScrollView setContentOffset:CGPointMake(0, temp * lineHeight) animated:YES];
//        }
//    }
}


@end
