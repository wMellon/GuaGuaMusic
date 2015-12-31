//
//  SingersTableViewController.m
//  呱呱音乐
//
//  Created by xxb on 15/12/16.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import "ArtistsTableViewController.h"
#import "MusicNetKit.h"
#import "GGArtistViewModel.h"
#import "SongsTableViewController.h"

@interface ArtistsTableViewController ()

@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ArtistsTableViewController

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
    
    for(NSDictionary *dict in _artistList){
        GGArtistViewModel *singerViewModel = [[GGArtistViewModel alloc] init];
        singerViewModel.artistId = dict[@"artistid"];
        singerViewModel.artistName = dict[@"artistname"];
        singerViewModel.artistPic = dict[@"artistpic"];
        [self.dataSource addObject:singerViewModel];
    }
    [self.tableView reloadData];
}

#pragma mark  UITableViewDataSource

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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    GGArtistViewModel *singerViewModel = _dataSource[indexPath.row];
    cell.textLabel.text = singerViewModel.artistName;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:singerViewModel.artistPic]];
    UIImage *image = [UIImage imageWithData:data];
    [cell.imageView setImage:image];
    return cell;
    
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GGArtistViewModel *artistViewModel = _dataSource[indexPath.row];
    SongsTableViewController *songsVC = [[SongsTableViewController alloc] init];
    songsVC.artistId = artistViewModel.artistId;
    songsVC.title = artistViewModel.artistName;
    [self.navigationController pushViewController:songsVC animated:YES];
}

@end
