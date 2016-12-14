//
//  ConnectVC.m
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "ConnectVC.h"

@interface ConnectVC ()
@property (weak, nonatomic) IBOutlet UIButton *btQuit;
@property (weak, nonatomic) IBOutlet UIImageView *ivConnect;

@end


typedef enum EWaitState {
    EWaitNone = 0,
    EWaitLeft,
    EWaitRight
} EWaitState;

static EWaitState sWaitState = EWaitNone;

@implementation ConnectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidAppear:(BOOL)animated {
    if ([self userLeft] == nil) {
        [self waitLeft];
    }
    else {
        [[self gvLeft] setUser:[self userLeft] welcome:LOREM_IPSUM];
        [self waitRight];
    }
    
}



- (IBAction)onQuitClicked:(id)sender {
    [SVProgressHUD dismiss];
    sWaitState = EWaitNone;
    [[self navigationController] popViewControllerAnimated:YES];
}



- (void)waitLeft {
    sWaitState = EWaitLeft;
    [SVProgressHUD showProgress:-1 status:@"En attente du premier bracelet..."];
    
}


- (void)waitRight {
    sWaitState = EWaitRight;
    [SVProgressHUD showProgress:-1 status:@"En attente du deuxième bracelet..."];
}


- (void)animateConnect {
    
}


// ============================================================================
#pragma mark - BLEManagerDelegate
// ============================================================================
- (void)bleDidStopScan:(BLEManager *)aManager {
    
}
- (void)ble:(BLEManager *)aManager didDisconnectfromPeripheral:(CBPeripheral *)aPeripheral {
//    [[self btSettings] setImage:sDisconnected forState:UIControlStateNormal];
}
- (void)ble:(BLEManager *)aManager didConnectToPeripheral:(CBPeripheral *)aPeripheral {
//    [[self btSettings] setImage:sConnected forState:UIControlStateNormal];
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
}


- (void)onGetUserFromNFCID:(NSString *)aNFCID user:(GenericUser *)aUser withError:(NSError *)aError {
    [SVProgressHUD dismiss];
    if(aError) {
        // TODO:
    }
    else {
        
        if(sWaitState == EWaitLeft) {
            [self setUserLeft:aUser];
            [[self gvLeft] setUser:aUser welcome:LOREM_IPSUM];
            [self waitRight];
        }
        else if(sWaitState == EWaitRight && [[aUser ident] isEqualToString:[[self userLeft] ident]] == NO) {
            [self setUserRight:aUser];
            [[self gvRight] setUser:aUser welcome:LOREM_IPSUM];
            sWaitState = EWaitNone;
        
            [self animateConnect];
            [ServerManager requestConnect:aUser with:[[self gvLeft] user]];
        }
        
        
    }
}


- (void)onGetAllUsers:(NSArray *)aUsers withError:(NSError *)aError {
    
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
