//
//  SocketManager.m
//  maxoucard_app
//
//  Created by Olivier on 11/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "SocketManager.h"


#define WSOCK_DEFAULT_PORT        81

static SocketManager * sInstance = nil;

@interface SocketManager ()
@property (retain, nonatomic) NSMutableArray * delegates;
@property (nonatomic, strong) PSWebSocket * clientSocket;
//@property BOOL connected;
@end


@implementation SocketManager

+ (SocketManager *)instance {
    if(sInstance == nil) {
        sInstance = [[SocketManager alloc] init];
        [sInstance setDelegates:[NSMutableArray array]];
//        [sInstance setConnected:NO];
    }
    return sInstance;
}


- (void)connectToSocket:(NSString *)aURL {
    NSString * url = [NSString stringWithFormat:@"ws://%@:%d", aURL, WSOCK_DEFAULT_PORT];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:/*@"ws://192.168.4.1:81"*/url]];
    [self setClientSocket: [PSWebSocket clientSocketWithRequest:request]];
    [[self clientSocket] setDelegate:self];
    [[self clientSocket] open];
}


- (void)sendMessage:(NSString *)aMessage {
    [[self clientSocket] send:aMessage];
}


- (void)closeSocket {
    [[self clientSocket] close];
}


- (void)registerDelegate:(id<SocketManagerDelegate>)aDelegate {
    if([[self delegates] indexOfObject:aDelegate] == NSNotFound) {
        [[self delegates] addObject:aDelegate];
    }
}


// ===========================================================================
#pragma mark - PSWebSocketDelegate
// ===========================================================================
- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"The websocket handshake completed and is now open!");
    for(id<SocketManagerDelegate> d in [self delegates]) {
        if([d respondsToSelector:@selector(webSocketDidOpen:)]) {
            [d webSocketDidOpen:webSocket];
        }
    }
}
- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"The websocket received a message: %@", message);
    if([message isKindOfClass:[NSData class]]) {
        NSData * data = (NSData *)message;
        if([data length] <= 4) {
            // value
            uint32_t value = *(uint32_t *)([data bytes]);
            for(id<SocketManagerDelegate> d in [self delegates]) {
                [d onSocketDidReceiveValue:value ofSize:(size_t)[data length]];
            }
        }
        else {
            // binary buffer
            for(id<SocketManagerDelegate> d in [self delegates]) {
                [d onSocketDidReceiveData:data];
            }
        }
    }
    else if([message isKindOfClass:[NSString class]]){
        // text
        NSString * str = [[NSString alloc] initWithData:message encoding:NSASCIIStringEncoding];
        for(id<SocketManagerDelegate> d in [self delegates]) {
            [d onSocketDidReceiveString:str];
        }
    }
}
- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"The websocket handshake/connection failed with an error: %@", error);
    for(id<SocketManagerDelegate> d in [self delegates]) {
        if([d respondsToSelector:@selector(webSocket:didFailWithError:)]) {
            [d webSocket:webSocket didFailWithError:error];
        }
    }
}
- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"The websocket closed with code: %@, reason: %@, wasClean: %@", @(code), reason, (wasClean) ? @"YES" : @"NO");
    for(id<SocketManagerDelegate> d in [self delegates]) {
        if([d respondsToSelector:@selector(webSocket:didCloseWithCode:reason:wasClean:)]) {
            [d webSocket:webSocket didCloseWithCode:code reason:reason wasClean:wasClean];
        }
    }
}



@end
