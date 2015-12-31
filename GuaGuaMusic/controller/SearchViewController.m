//
//  singersTableViewController.m
//  呱呱音乐
//
//  Created by xxb on 15/12/15.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import "SearchViewController.h"
#import "MusicNetKit.h"
#import "LrcRemoteViewController.h"
#import "GGSongViewModel.h"
#import "XBSlidingViewController.h"
#import "SongsTableViewController.h"
#import "ArtistsTableViewController.h"

#define SEARCHED_KEY @"searchKey"

@interface SearchViewController ()<UISearchBarDelegate>{
    
}

@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) UISearchBar *searchBar;

@end

@implementation SearchViewController

#pragma mark - view生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self commonInit];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //获取沙盒中的最新10条查询数据
    [self loadDataSource];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - init初始化

-(void)commonInit{
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    //初始化搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
}

-(void)loadDataSource{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *searchKeys = [userDefaults arrayForKey:SEARCHED_KEY];
    if(searchKeys){
        //反序
        NSMutableArray *tempSearchKeys = [searchKeys mutableCopy];
        switch (searchKeys.count) {
            case 0:
            case 1:
                break;
            case 2:
                [tempSearchKeys exchangeObjectAtIndex:0 withObjectAtIndex:1];
            default:{
                for(int i = 0; i < tempSearchKeys.count / 2 - 1; i ++){
                    [tempSearchKeys exchangeObjectAtIndex:i withObjectAtIndex:tempSearchKeys.count - 1 - i];
                }
            }
                break;
        }
        self.dataSource = tempSearchKeys;
        [self.tableView reloadData];
    }
}

#pragma mark - delegate

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if(![NSString isBlankString:searchBar.text]){
        [self searchWith:searchBar.text];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
    
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *searchText = _dataSource[indexPath.row];
    [self searchWith:searchText];
}

#pragma mark - action

-(void)searchWith:(NSString*)searchText{
    //存储到沙盒中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *searchKeys = [userDefaults arrayForKey:SEARCHED_KEY];
    if(searchKeys){
        NSMutableArray *tempSearchKeys = [searchKeys mutableCopy];
        //去重
        if([tempSearchKeys containsObject:searchText]){
            [tempSearchKeys removeObject:searchText];
        }
        //取前9
        if(tempSearchKeys.count >= 10){
            tempSearchKeys = [[tempSearchKeys subarrayWithRange:NSMakeRange(tempSearchKeys.count - 9, 9)] mutableCopy];
        }
        [tempSearchKeys addObject:searchText];
        [userDefaults setObject:tempSearchKeys forKey:SEARCHED_KEY];
    }else{
        NSArray *array = @[searchText];
        [userDefaults setObject:array forKey:SEARCHED_KEY];
    }
    
    [self showHud];
    [MusicNetKit searchWith:searchText completionHandler:^(NSString *data) {
        [self hideHud];
        if(data){
            //为什么substringWithRange不行？
            NSString *result = [data substringFromIndex:5];
            result = [result substringToIndex:result.length - 2];
            NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            NSArray *array = [dict allKeys];
            XBSlidingViewController *slideVC = [[XBSlidingViewController alloc] init];
            NSMutableArray *controllers = [[NSMutableArray alloc] init];
            if([array containsObject:@"song"]){
                //歌名song
                SongsTableViewController *songsVC = [[SongsTableViewController alloc] init];
                songsVC.songList = dict[@"song"];
                songsVC.title = @"歌曲";
                [controllers addObject:songsVC];
            }
            if([array containsObject:@"artist"]){
                //歌手artist
                ArtistsTableViewController *singersVC = [[ArtistsTableViewController alloc] init];
                singersVC.artistList = dict[@"artist"];
                singersVC.title = @"歌手";
                [controllers addObject:singersVC];
            }
            if([array containsObject:@"album"]){
                //专辑album
            }
            
            slideVC.controllers = controllers;
            slideVC.unselectedLabelColor = [UIColor brownColor];
            slideVC.selectedLabelColor = [UIColor redColor];
            slideVC.title = @"搜索结果";
            [self.navigationController pushViewController:slideVC animated:YES];
        }
    }];
}

@end
