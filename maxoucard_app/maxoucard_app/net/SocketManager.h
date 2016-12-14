//
//  SocketManager.h
//  maxoucard_app
//
//  Created by Olivier on 11/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//
#import "Config.h"
#import "PSWebSocket.h"
#import <Foundation/Foundation.h>
#import "../../../maxoucard_wifi/wsock_commands.h"



@protocol SocketManagerDelegate <PSWebSocketDelegate>
- (void)onSocketDidReceiveValue:(uint32_t)aValue ofSize:(size_t)aSize;
- (void)onSocketDidReceiveData:(NSData *)aValue;
- (void)onSocketDidReceiveString:(NSString *)aValue;
@end

@interface SocketManager : NSObject <PSWebSocketDelegate>
+ (SocketManager *)instance;
- (void)connectToSocket:(NSString *)aURL ;
- (void)sendMessage:(NSString *)aMessage;
- (void)closeSocket;
- (void)registerDelegate:(id<SocketManagerDelegate>)aDelegate;
- (void)configureAPSSID:(NSString *)aSSID pass:(NSString *)aPass;
@end
