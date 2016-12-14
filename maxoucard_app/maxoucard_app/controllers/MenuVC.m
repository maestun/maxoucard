//
//  MenuVC.m
//  maxoucard_app
//
//  Created by Olivier on 11/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "MenuVC.h"
#import "RouterAndRoutes.h"

@interface MenuVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfRemoteServer;
@property (weak, nonatomic) IBOutlet UITextField *tfSoftAP;
@property (weak, nonatomic) IBOutlet UIButton *btTestRemoteServer;
@property (weak, nonatomic) IBOutlet UIButton *btTestSoftAP;
@property (weak, nonatomic) IBOutlet UITableView *tvUsers;
@property (weak, nonatomic) IBOutlet UIButton *btReassign;
@property (weak, nonatomic) IBOutlet UIButton *btChangePassword;
@end

@implementation MenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SocketManager instance] registerDelegate:self];
    
    // try to connect to websocket server that runs on softAP
    NSString * softAP =  [Route_Info getRouterIpAddress];
    [[self tfSoftAP] setText:softAP];
    [[SocketManager instance] connectToSocket:softAP];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onTestRemoteServerClicked:(id)sender {
    // send message to web socket
    [[self btTestRemoteServer] setEnabled:NO];
    NSString * str = [NSString stringWithFormat:@"%@%@%@", STRINGIFY(WSOCK_COMMAND_REMOTE),
                      STRINGIFY(WSOCK_COMMAND_SEPARATOR), [[self tfRemoteServer] text]];
    [[SocketManager instance] sendMessage:str];
}


- (IBAction)onTestSoftAPClicked:(id)sender {
    [[self btTestSoftAP] setEnabled:NO];
    [[SocketManager instance] connectToSocket:[[self tfSoftAP] text]];
}


- (IBAction)onReassignClicked:(id)sender {
}


- (IBAction)onChangePasswordClicked:(id)sender {
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"Administration" message:@"Changement du mot de passe:" preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setSecureTextEntry:YES];
        [textField setPlaceholder:@"Mot de passe actuel"];
    }];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setSecureTextEntry:YES];
        [textField setPlaceholder:@"Nouveau mot de passe"];
    }];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setSecureTextEntry:YES];
        [textField setPlaceholder:@"Nouveau mot de passe"];
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * old = [[[ac textFields] objectAtIndex:0] text];
        NSString * p1 = [[[ac textFields] objectAtIndex:1] text];
        NSString * p2 = [[[ac textFields] objectAtIndex:2] text];
        
        if([old isEqualToString:[Config getPassword]] == NO) {
            UIAlertController * err = [UIAlertController alertControllerWithTitle:@"Erreur" message:@"L'ancien mot de passe est erroné." preferredStyle:UIAlertControllerStyleAlert];
            [err addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:err animated:YES completion:nil];
            
        }
        else if([p1 isEqualToString:p2]) {
            [Config setPassword:p1];
        }
        else {
            UIAlertController * err = [UIAlertController alertControllerWithTitle:@"Erreur" message:@"Les mots de passe ne correspondent pas." preferredStyle:UIAlertControllerStyleAlert];
            [err addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:err animated:YES completion:nil];
        }
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}


// ===========================================================================
#pragma mark - SocketManagerDelegate
// ===========================================================================
- (void)onSocketDidReceiveString:(NSString *)aValue {
    // try to parse messages
    NSArray * data = [aValue componentsSeparatedByString:STRINGIFY(WSOCK_COMMAND_SEPARATOR)];
    NSError * err = nil;
    if([aValue hasPrefix:STRINGIFY(WSOCK_COMMAND_REMOTE)]) {
        if([data count] == 2 && [data[1] isEqualToString:STRINGIFY(WSOCK_OK)]) {
            // TODO: remote server set into softAP, try to ping
            [ServerManager testServer:[[self tfRemoteServer] text] delegate:self];
        }
        else {
            // TODO: handle error
            
        }
    }
    else if([aValue hasPrefix:STRINGIFY(WSOCK_COMMAND_NFC)]) {
        if([data count] == 3 && [data[2] isEqualToString:STRINGIFY(WSOCK_OK)]) {
            // TODO: fetch NFC
        }
        else {
            // TODO: handle error
        }
    }
    else if([aValue hasPrefix:STRINGIFY(WSOCK_COMMAND_AP)]) {
        if([data count] == 2 && [data[1] isEqualToString:STRINGIFY(WSOCK_OK)]) {
            // TODO: configured AP successfully ! try to ping remote server
        }
    }
    else {
        // TODO: handle other data
    }
    
}
- (void)onSocketDidReceiveData:(NSData *)aValue {
    
}
- (void)onSocketDidReceiveValue:(uint32_t)aValue ofSize:(size_t)aSize {
    
}
- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    [[self btTestSoftAP] setEnabled:YES];
//    [SVProgressHUD showSuccessWithStatus:@"Serveur WebSocket Local OK !"];
}
- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    
}
- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
}
- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
}


// ===========================================================================
#pragma mark - ServerManagerDelegate
// ===========================================================================
- (void)onTestServer:(NSError *)aError version:(NSString *)aVersion {
    if(aError == nil) {
        // test OK !
        [[self btTestRemoteServer] setEnabled:YES];
        [SVProgressHUD showSuccessWithStatus:@"Serveur HTTP Distant OK !"];
    }
}
- (void)onGetAllUsers:(NSArray *)aUsers withError:(NSError *)aError {
    
}
- (void)onGetUserFromNFCID:(NSString *)aNFCID user:(GenericUser *)aUser withError:(NSError *)aError {
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
