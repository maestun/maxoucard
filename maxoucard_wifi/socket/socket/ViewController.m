//
//  ViewController.m
//  socket
//
//  Created by Olivier on 10/12/2016.
//  Copyright © 2016 cdv. All rights reserved.
//

#import "ViewController.h"
#import "PSWebSocket.h"
#import "PSWebSocketServer.h"
#import "SocketRocket.h"

@interface ViewController () <SRWebSocketDelegate, PSWebSocketDelegate, UITextFieldDelegate>
@property (nonatomic, strong) PSWebSocket *clientSocket;
//@property (nonatomic, strong) SRWebSocket *socket;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UILabel *lbMessage;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // create the NSURLRequest that will be sent as the handshake

    
    [[self textfield] setDelegate:self];
//
    
//    self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://192.168.1.10:8080"]];
//    self.socket.delegate = self;
//    [self.socket open];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClientClicked:(id)sender {
    static BOOL on = YES;
    
    //[[self clientSocket] send:@"WIFI;paprika2;WIFI12Stones"];
    
    [self.clientSocket send:on ? @"L1" : @"L0"];
    on = !on;
}

- (IBAction)onServerClicked:(id)sender {
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://192.168.4.1:81"]];
    
    //    // create the socket and assign delegate
    self.clientSocket = [PSWebSocket clientSocketWithRequest:request];
    self.clientSocket.delegate = self;
    //
    //    // open socket
    [self.clientSocket open];
    
}
- (IBAction)onRequestClicked:(id)sender {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.4.1:80"]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    [NSURLConnection sendAsynchronousRequest:request
                                   queue:queue
                       completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                                       ;
                       }];
    
    
}

// ===========================================================================
#pragma mark - SRWebSocketDelegate
// ===========================================================================
//- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
//    
//}
//-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
//    
//}


// ===========================================================================
#pragma mark - PSWebSocketDelegate
// ===========================================================================
- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"The websocket handshake completed and is now open!");
    [webSocket send:@"Hello world!"];
}
- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"The websocket received a message: %@", message);
//    [[self lbMessage] setText:[NSString stringWithFormat:@"%@\n%@", [[self lbMessage] text], message]];
    if([message isKindOfClass:[NSData class]]) {
//        unsigned int value = CFSwapInt32BigToHost(*(unsigned int*)([message bytes]));
        int value = *(int*)([message bytes]);
        [[self lbMessage] setText:[NSString stringWithFormat:@"%d", value]];
    }
    else if([message isKindOfClass:[NSString class]]){
        [[self lbMessage] setText:message];
    }
}
- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"The websocket handshake/connection failed with an error: %@", error);
}
- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"The websocket closed with code: %@, reason: %@, wasClean: %@", @(code), reason, (wasClean) ? @"YES" : @"NO");
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(string != nil) {
        [[self clientSocket] send:string];
    }
    return YES;
}


// ===========================================================================
#pragma mark - PSWebSocketServerDelegate
// ===========================================================================
//- (void)serverDidStart:(PSWebSocketServer *)server {
//}
//- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error{
//}
//- (void)serverDidStop:(PSWebSocketServer *)server{
//}
//
//- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket{
//}
//- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message{
//}
//- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error{
//}
//- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
//}



@end
