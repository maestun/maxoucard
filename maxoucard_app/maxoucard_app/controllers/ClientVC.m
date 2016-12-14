//
//  ClientVC.m
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "ClientVC.h"
#import "Config.h"
#import <AFNetworking.h>


#define NO_PASSWORD     1


@interface ClientVC ()
@property (weak, nonatomic) IBOutlet UIWebView *wvMain;
@property (weak, nonatomic) IBOutlet UIButton *btConnect;
@property (weak, nonatomic) IBOutlet UIButton *btSettings;
@property (weak, nonatomic) IBOutlet UIImageView *ivBackground;
@property (weak, nonatomic) IBOutlet GenericUserView *gvUser;

@end


static UIImage * sConnected = nil;
static UIImage * sDisconnected = nil;



@implementation ClientVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;

    sConnected = [ACUtils tintedImageWithColor:FlatGreen image:[UIImage imageNamed:@"gears"]];
    sDisconnected = [ACUtils tintedImageWithColor:FlatGray image:[UIImage imageNamed:@"gears"]];
    
    [[self btSettings] setImage:sDisconnected forState:UIControlStateNormal];

        [[BLEManager instance] registerDelegate:self];
}


- (void)viewWillAppear:(BOOL)animated {
    // check network
    [ServerManager testServer:[Config getServerURL] delegate:self];
}



- (IBAction)onSettingsClicked:(id)sender {

#ifdef DEBUG
    [[self sideMenuViewController] setContentViewInLandscapeOffsetCenterX:(CGRectGetWidth([[self view] frame]) / 2) - 60];
    [super presentLeftMenuViewController:sender];
#else
    
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"Administration" message:@"Veuillez entrer le mot de passe:" preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setSecureTextEntry:YES];
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * passwd = [[[ac textFields] objectAtIndex:0] text];
        
        
        // TODO: disable no passwd !!
        if([passwd isEqualToString:[Config getPassword]]) {
            [[self sideMenuViewController] setContentViewInLandscapeOffsetCenterX:(CGRectGetWidth([[self view] frame]) / 2) - 60];
            [super presentLeftMenuViewController:sender];
        }
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];

    [self presentViewController:ac animated:YES completion:^{
        
    }];
#endif
}




- (IBAction)onConnectClicked:(id)sender {

    ConnectVC * vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"idConnectVC"];
//    [self setDeviceDelegate:vc];
    
    if([[self gvUser] user]) {
        [vc setUserLeft:[[self gvUser] user]];
    }
    [[self navigationController] pushViewController:vc animated:YES];

}



// ============================================================================
#pragma mark - BLEManagerDelegate
// ============================================================================
- (void)ble:(BLEManager *)aManager didDisconnectfromPeripheral:(CBPeripheral *)aPeripheral {
    [[self btSettings] setImage:sDisconnected forState:UIControlStateNormal];
}
- (void)ble:(BLEManager *)aManager didConnectToPeripheral:(CBPeripheral *)aPeripheral {
    [[self btSettings] setImage:sConnected forState:UIControlStateNormal];
}
- (void)ble:(BLEManager *)aManager didReceiveNFCID:(NSString *)aNFCID {
    // data shound be NFC ID
    [SVProgressHUD showProgress:-1 status:@"Récupération de vos informations..."];
    [ServerManager getUserFromNFCID:aNFCID delegate:self];
}


// ============================================================================
#pragma mark - ServerManagerDelegate
// ============================================================================
- (void)onTestServer:(NSError *)aError version:(NSString *)aVersion {
    if(aError) {
        UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"Erreur" message:@"Impossible de joindre le serveur, veuillez vérifier la connectivité !" preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"Réglages iOS" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        }]];
        [ac addAction:[UIAlertAction actionWithTitle:@"Administration" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self onSettingsClicked:nil];
        }]];
        [ac addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    }
    else {
        // TODO: skin app
    }
}


- (void)onGetUserFromNFCID:(NSString *)aNFCID user:(GenericUser *)aUser withError:(NSError *)aError {
    [SVProgressHUD dismiss];
    if(aError) {
        
    }
    else {
        // show data
        [[self gvUser] setUser:aUser welcome:LOREM_IPSUM];
    }
}


- (void)onGetAllUsers:(NSArray *)aUsers withError:(NSError *)aError {
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
