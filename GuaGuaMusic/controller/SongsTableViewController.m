//
//  SongsTableViewController.m
//  呱呱音乐
//
//  Created by xxb on 15/12/16.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import "SongsTableViewController.h"
#import "LrcRemoteViewController.h"
#import "GGSongViewModel.h"
#import "MusicNetKit.h"
#import "ResponseViewModel.h"

@interface SongsTableViewController ()

@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation SongsTableViewController

#pragma mark - view生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - init初始化

-(void)commonInit{
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
    if(_songList){
        for(NSDictionary *dict in _songList){
            GGSongViewModel *songViewModel = [[GGSongViewModel alloc] init];
            songViewModel.songId = [NSString isBlankString:dict[@"songId"]] ? dict[@"songid"] : dict[@"songId"];
            songViewModel.songName = dict[@"songname"];
            songViewModel.authorName = dict[@"artistname"];
            [_dataSource addObject:songViewModel];
        }
        [self.tableView reloadData];
    }
    if(_artistId){
        [self showHud];
        [MusicNetKit getSongListBy:_artistId completionHandler:^(ResponseViewModel *response) {
            [self hideHud];
            if(response.success){
                NSDictionary *songList = response.responseData;
                if([[songList allKeys] containsObject:@"songlist"]){
                    _dataSource = [[NSMutableArray alloc] init];
                    NSArray *array = songList[@"songlist"];
                    for(NSDictionary *dict in array){
                        GGSongViewModel *songViewModel = [[GGSongViewModel alloc] init];
                        songViewModel.songId = dict[@"song_id"];
                        songViewModel.songName = dict[@"title"];
                        songViewModel.authorName = dict[@"author"];
                        [_dataSource addObject:songViewModel];
                    }
                    [self.tableView reloadData];
                }
            }else{
                [self showErrorHud:response.errorInfo];
            }
        }];
    }
}

#pragma mark  Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    static NSString *cellIdentifier = @"song";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    GGSongViewModel *songViewModel = _dataSource[indexPath.row];
    cell.textLabel.text = songViewModel.songName;
    cell.detailTextLabel.text = songViewModel.authorName;
    return cell;
    
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GGSongViewModel *songViewModel = _dataSource[indexPath.row];
    LrcRemoteViewController *play = [[LrcRemoteViewController alloc] init];
    play.songId = songViewModel.songId;
    play.title = songViewModel.songName;
    [self.navigationController pushViewController:play animated:YES];
}

@end
