//
//  SettingsVC.m
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "SettingsVC.h"
#import "ClientVC.h"

#define SCAN_TIMEOUT            5

#define TAG_DEVICES             1
#define TAG_USERS               2

static volatile BOOL            sScanning = NO;
static volatile BOOL            sRefreshing = NO;


@interface SettingsVC ()
@property (weak, nonatomic) IBOutlet UITextField *tfServerURL;
@property (weak, nonatomic) IBOutlet UIButton *btServer;
@property (weak, nonatomic) IBOutlet UITableView *tvDevices;
@property (weak, nonatomic) IBOutlet UIButton *btScan;
@property (weak, nonatomic) IBOutlet UITableView *tvUsers;
@property (weak, nonatomic) IBOutlet UIButton *btReassign;
@property (weak, nonatomic) IBOutlet UIButton *btPassword;


@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[self tvUsers] setTag:TAG_USERS];
    [[self tvUsers] setDelegate:self];
    [[self tvUsers] setDataSource:self];

    [[self tvDevices] setTag:TAG_DEVICES];
    [[self tvDevices] setDelegate:self];
    [[self tvDevices] setDataSource:self];
    
    
    mRefreshDevices = [[UIRefreshControl alloc] init];
    [[self tvDevices] addSubview:mRefreshDevices];
    [mRefreshDevices addTarget:[BLEManager instance] action:@selector(startScan) forControlEvents:UIControlEventValueChanged];
    
    
    mRefreshUsers = [[UIRefreshControl alloc] init];
    [[self tvUsers] addSubview:mRefreshUsers];
    [mRefreshUsers addTarget:self action:@selector(refreshUsers) forControlEvents:UIControlEventValueChanged];
    

    [[self tfServerURL] setText:[Config getServerURL]];
    

    [[BLEManager instance] registerDelegate:self];
    
    [ServerManager getAllUsers:self];
    
    // start scan w/ some delay or CoreBluetooth won't be initialized !
    [NSTimer scheduledTimerWithTimeInterval:1 target:[BLEManager instance] selector:@selector(startScan) userInfo:nil repeats:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onServerClicked:(id)sender {
    [ServerManager testServer:[[self tfServerURL] text] delegate:self];
}


- (IBAction)onScanClicked:(id)sender {
    [[BLEManager instance] startScan];
}


- (IBAction)onReassignClicked:(id)sender {
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"ATTENTION" message:@"Vous allez lancer la réassignation NFC de TOUS les utilisateurs, êtes vous sûr ?" preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self askReassignPassword];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:ac animated:YES completion:^{
        
    }];
}


- (IBAction)onPasswordClicked:(id)sender {
    
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


- (void)askReassignPassword {
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"Administration" message:@"Veuillez entrer le mot de passe:" preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setSecureTextEntry:YES];
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * passwd = [[[ac textFields] objectAtIndex:0] text];
        if([passwd isEqualToString:[Config getPassword]]) {
            // TODO: lancer reassign
            
        }
        else {
            UIAlertController * err = [UIAlertController alertControllerWithTitle:@"Erreur" message:@"Le mot de passe est erroné." preferredStyle:UIAlertControllerStyleAlert];
            [err addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:err animated:YES completion:nil];
        }
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:ac animated:YES completion:^{
        
    }];
}


// ============================================================================
#pragma mark - BLEManagerDelegate
// ============================================================================
- (void)ble:(BLEManager *)aManager didFindPeripheral:(CBPeripheral *)aPeripheral {
    [[self tvDevices] reloadData];
}
- (void)ble:(BLEManager *)aManager didDisconnectfromPeripheral:(CBPeripheral *)aPeripheral {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Déconnexion de %@", [aPeripheral name]]];
    [[self tvDevices] reloadData];
}
- (void)ble:(BLEManager *)aManager didConnectToPeripheral:(CBPeripheral *)aPeripheral {
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Connecté à %@", [aPeripheral name]]];
    [[self tvDevices] reloadData];
}
- (void)bleDidStartScan:(BLEManager *)aManager {
    [self refreshScanUI:YES];
}
- (void)bleDidStopScan:(BLEManager *)aManager {
    [self refreshScanUI:NO];
}
- (void)ble:(BLEManager *)aManager didReceiveNFCID:(NSString *)aNFCID {
    
    // comm server
    [ServerManager getUserFromNFCID:aNFCID delegate:self];

}
- (void)ble:(BLEManager *)aManager error:(NSError *)aError {
    [SVProgressHUD showErrorWithStatus:@"Veuillez activer le Bluetooth dans Réglages."];
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
        [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    }
    else {
        [SVProgressHUD showSuccessWithStatus:@"Connexion réussie !"];
        [Config setServerURL:[[self tfServerURL] text]];
    }
}


- (void)onGetAllUsers:(NSArray *)aUsers withError:(NSError *)aError {
    
    sRefreshing = NO;
    [mRefreshUsers endRefreshing];
    if(aError == nil){
        mUsers = [NSMutableArray arrayWithArray:aUsers];
        [[self tvUsers] reloadData];
    }
}


- (void)onGetUserFromNFCID:(NSString *)aNFCID user:(GenericUser *)aUser withError:(NSError *)aError {
    // TODO:
    
}



// ============================================================================
#pragma mark - UITableView
// ============================================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableView tag] == TAG_DEVICES ? [[[BLEManager instance] peripherals] count] : [mUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if([tableView tag] == TAG_DEVICES) {
    
        static NSString *cellId = @"peripheral";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        }
        
        CBPeripheral *peripheral = [[[BLEManager instance] peripherals] objectAtIndex:[indexPath row]];
        [[cell textLabel] setText:[peripheral name]];
        [[cell textLabel] setFont:FONT_BOLD(FONT_SZ_MEDIUM)];
//        [[cell textLabel] setTextColor:TEXT_COLOR_WHITE];
        [[cell detailTextLabel] setText:[[peripheral identifier] UUIDString]];
        [[cell detailTextLabel] setFont:FONT(FONT_SZ_SMALL)];
//        [[cell detailTextLabel] setTextColor:TEXT_COLOR_WHITE];
        
        UIColor * c = FlatOrange;
        if([peripheral state] == CBPeripheralStateConnected) {
            c = FlatGreen;
        }
        else if([peripheral state] == CBPeripheralStateDisconnected) {
            c = FlatRed;
        }
        
        CGFloat sz = 24;
        [[cell imageView] setImage:[ACUtils imageFromColor:c andSize:CGSizeMake(sz, sz)]];
        [[cell imageView] setContentMode:UIViewContentModeScaleToFill];
        [[[cell imageView] layer] setCornerRadius:(sz / 2)];
        
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        static NSString *cellId2 = @"user";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId2];
        }
        NSDictionary * user = [mUsers objectAtIndex:[indexPath row]];

        [[cell textLabel] setText:[NSString stringWithFormat:@"%@ %@", [user objectForKey:@"fname"], [user objectForKey:@"lname"]]];
        [[cell textLabel] setFont:FONT_BOLD(FONT_SZ_MEDIUM)];
//        [[cell textLabel] setTextColor:TEXT_COLOR_WHITE];
        [[cell detailTextLabel] setText:[user objectForKey:@"email"]];
        [[cell detailTextLabel] setFont:FONT(FONT_SZ_SMALL)];
//        [[cell detailTextLabel] setTextColor:TEXT_COLOR_WHITE];
        
        CGFloat sz = 24;
        NSDictionary * pics = [user objectForKey:@"picture"];
        NSString * img = [pics objectForKey:@"thumbnail"];
        [[cell imageView] sd_setImageWithURL:[NSURL URLWithString:img] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            ;
        }];
//        [[cell imageView] setContentMode:UIViewContentModeScaleToFill];
        [[[cell imageView] layer] setCornerRadius:(sz / 2)];
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated: true];
    
    if([tableView tag] == TAG_DEVICES) {
        [self refreshScanUI:NO];
        CBPeripheral * p = [[[BLEManager instance] peripherals] objectAtIndex:[indexPath row]];
        [[BLEManager instance] connectToPeripheral:p];
    }
    else {
        
    }
}




// ============================================================================
#pragma mark - Network Connectivity
// ============================================================================
- (void)refreshUsers {
    sRefreshing = YES;
    [ServerManager getAllUsers:self];
}

- (void)refreshScanUI:(BOOL)aIsScanning {
    sScanning = aIsScanning;
    [[self btScan] setEnabled:!aIsScanning];
    if(aIsScanning == NO) {
        [mRefreshDevices endRefreshing];
    }
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
