//
//  ServerManager.h
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#import "GenericUser.h"

@protocol ServerManagerDelegate <NSObject>
- (void)onTestServer:(NSError *)aError version:(NSString *)aVersion;
- (void)onGetAllUsers:(NSArray *)aUsers withError:(NSError *)aError;
- (void)onGetUserFromNFCID:(NSString *)aNFCID user:(GenericUser *)aUser withError:(NSError *)aError;
@end

@interface ServerManager : NSObject

+ (void)testServer:(NSString *)aURL delegate:(id<ServerManagerDelegate>)aDelegate ;
+ (void)getAllUsers:(id<ServerManagerDelegate>)aDelegate ;
+ (void)getUserFromNFCID:(NSString *)aNFCID delegate:(id<ServerManagerDelegate>)aDelegate ;
+ (void)requestConnect:(GenericUser *)aUser1 with:(GenericUser *)aUser2;

@end
