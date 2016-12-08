//
//  ServerManager.m
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "ServerManager.h"

#define URL_SKIN        @"skin"
#define URL_USERS       @"users"
#define URL_BADGES      @"nfc_badges"
#define URL_INFO        @"info"
#define URL_USER_NFC    @"user"



@implementation ServerManager

+ (void)testServer:(NSString *)aURL delegate:(id<ServerManagerDelegate>)aDelegate {
    NSString * url  = [NSString stringWithFormat:@"%@/%@", aURL, URL_INFO];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary * dic = (NSDictionary *)responseObject;
        [aDelegate onTestServer:nil version: [dic objectForKey:@"version"]];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [aDelegate onTestServer:error version:nil];
    }];
}


+ (void)getAllUsers:(id<ServerManagerDelegate>)aDelegate {
    
}


+ (void)getUserFromBadgeID:(NSString *)aBadgeID delegate:(id<ServerManagerDelegate>)aDelegate {
    
    NSString * url  = [NSString stringWithFormat:@"%@/%@?id=%@", [Config getServerURL], URL_USER_NFC, aBadgeID];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}


@end
