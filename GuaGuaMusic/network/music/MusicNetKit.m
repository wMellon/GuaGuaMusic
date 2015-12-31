//
//  MusicNetKit.m
//  demo-xxb
//
//  Created by xxb on 15/12/14.
//  Copyright © 2015年 xxb. All rights reserved.
//

#import "MusicNetKit.h"
#import "AFNetworking.h"

@implementation MusicNetKit

+(void)getSongInformationWith:(NSString*)songId completionHandler:(void (^) (ResponseViewModel *response)) completionHandler{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/javascript"];
    ResponseViewModel *response = [[ResponseViewModel alloc] init];
    [manager GET:[NSString stringWithFormat:@"http://music.baidu.com/data/music/links?songIds=%@", songId] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        response.success = YES;
        response.responseData = responseObject;
        completionHandler(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        response.success = NO;
        response.errorInfo = error.localizedFailureReason;
        completionHandler(response);
    }];
}

+(void)getSongLrcWith:(NSString*)url completionHandler:(void (^) (ResponseViewModel *response)) completionHandler{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/x-www-form-urlencoded", @"application/lrc", @"text/plain",nil];
    ResponseViewModel *response = [[ResponseViewModel alloc] init];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSData *data = (NSData*)responseObject;
        response.success = YES;
        response.responseData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        completionHandler(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        response.success = NO;
        response.errorInfo = error.localizedFailureReason;
        completionHandler(response);
    }];
}

+(void)searchWith:(NSString*)keyword completionHandler:(void (^) (NSString *lrcContent)) completionHandler{
    NSString *url = [NSString stringWithFormat:@"http://tingapi.ting.baidu.com/v1/restserver/ting?from=ios&method=baidu.ting.search.catalogSug&format=json&callback=&query=%@&_=%.0f", keyword, [[NSDate date] timeIntervalSince1970]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSData *data = (NSData*)responseObject;
        completionHandler([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"error");
    }];
}

+(void)getSongListBy:(NSString*)singerId completionHandler:(void (^) (ResponseViewModel *response)) completionHandler{
    NSString *url = [NSString stringWithFormat:@"http://tingapi.ting.baidu.com//v1/restserver/ting?from=android&version=2.4.0&method=baidu.ting.artist.getSongList&format=json&order=2&tinguid=%@&offset=0&limits=800", singerId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    ResponseViewModel *response = [[ResponseViewModel alloc] init];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        response.success = YES;
        response.responseData = responseObject;
        completionHandler(response);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        response.success = NO;
        response.errorInfo = error.localizedFailureReason;
        completionHandler(response);
    }];
}

@end
