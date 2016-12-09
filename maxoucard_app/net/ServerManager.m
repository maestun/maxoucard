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
#define URL_PARAM_NFCID @"nfc"



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
    NSString * url  = [NSString stringWithFormat:@"%@/%@", [Config getServerURL], URL_USERS];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if([responseObject isKindOfClass:[NSArray class]]) {
            NSArray * users = (NSArray *)responseObject;
            [aDelegate onGetAllUsers:users withError:nil];
        }
        else {
            
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}


+ (void)getUserFromNFCID:(NSString *)aNFCID delegate:(id<ServerManagerDelegate>)aDelegate {
    
    NSString * url  = [NSString stringWithFormat:@"%@/%@?%@=%@", [Config getServerURL], URL_USERS, URL_PARAM_NFCID, aNFCID];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if([responseObject isKindOfClass:[NSArray class]]) {
            NSArray * arr = (NSArray *)responseObject;
            if([arr count] == 1) {
                NSDictionary * dic = [arr objectAtIndex:0];
                
                GenericUser * user = [[GenericUser alloc] init];
                [user setTitle:[dic objectForKey:@"title"]];
                [user setFname:[dic objectForKey:@"fname"]];
                [user setLname:[dic objectForKey:@"lname"]];
                [user setNfc:[dic objectForKey:@"nfc"]];
                [user setEmail:[dic objectForKey:@"email"]];
                [user setIdent:[dic objectForKey:@"id"]];
                [user setLinkedin:[dic objectForKey:@"linkedin"]];
                [user setPhone:[dic objectForKey:@"phone"]];
                
                NSDictionary * pics = [dic objectForKey:@"picture"];
                [user setBigpicURL:[pics objectForKey:@"large"]];

                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat: @"Bonjour %@ %@ !", [user fname], [user lname]]];

                [aDelegate onGetUserFromNFCID:aNFCID user:user withError:nil];
                
                
                // TODO: check-in user
                
                
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [aDelegate onGetUserFromNFCID:aNFCID user:nil withError:error];
    }];
    
}


+ (void)requestConnect:(GenericUser *)aUser1 with:(GenericUser *)aUser2 {
    
}


@end
