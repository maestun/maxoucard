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
    [mRefreshDevices addTarget:self action:@selector(startScan) forControlEvents:UIControlEventValueChanged];
    
    
    mRefreshUsers = [[UIRefreshControl alloc] init];
    [[self tvUsers] addSubview:mRefreshUsers];
    [mRefreshUsers addTarget:self action:@selector(refreshUsers) forControlEvents:UIControlEventValueChanged];
    

    [[self tfServerURL] setText:[Config getServerURL]];
    
    mSensor = [[SerialGATT alloc] init];
    [mSensor setup];
    [mSensor setDelegate:self];
    
    mPeripherals = [[NSMutableArray alloc] init];
    
    [ServerManager getAllUsers:self];
    
    // start scan w/ some delay or CoreBluetooth won't be initialized !
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startScan) userInfo:nil repeats:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onServerClicked:(id)sender {
    [ServerManager testServer:[[self tfServerURL] text] delegate:self];
}


- (IBAction)onScanClicked:(id)sender {
    [self startScan];
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


- (void)onGetUserFromNFCID:(NSString *)aNFCID user:(NSDictionary *)aUser withError:(NSError *)aError {
    // TODO:
}



// ============================================================================
#pragma mark - UITableView
// ============================================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableView tag] == TAG_DEVICES ? [mPeripherals count] : [mUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if([tableView tag] == TAG_DEVICES) {
    
        static NSString *cellId = @"peripheral";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        }
        
        CBPeripheral *peripheral = [mPeripherals objectAtIndex:[indexPath row]];
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
        [[cell imageView] setImageWithURL:[NSURL URLWithString:img]];
//        [[cell imageView] setContentMode:UIViewContentModeScaleToFill];
        [[[cell imageView] layer] setCornerRadius:(sz / 2)];
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated: true];
    
    if([tableView tag] == TAG_DEVICES) {
        CBPeripheral * p = [mPeripherals objectAtIndex:[indexPath row]];
        [self connectToPeripheral:p];
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



// ============================================================================
#pragma mark - BLE Connectivity
// ============================================================================
- (void)connectToPeripheral:(CBPeripheral *)aPeripheral {
    
    // stop scanning
    [self stopScan];
    
    // disconnect from current peripheral
    if([mSensor activePeripheral]) {
        [mSensor disconnect:[mSensor activePeripheral]];
    }
    
    // connect to peripheral
    [mSensor connect:aPeripheral];
    [mSensor setActivePeripheral:aPeripheral];
    
    [[self tvDevices] reloadData];
}


- (void)startScan {
    
    // disconnect from current connected peripheral
    if ([mSensor activePeripheral]) {
        if ([[mSensor activePeripheral] state] == CBPeripheralStateConnected) {
            [[mSensor manager] cancelPeripheralConnection:[mSensor activePeripheral]];
            [mSensor setActivePeripheral:nil];
        }
    }
    
    // remove peripheral cache from sensor
    if ([mSensor peripherals]) {
        [mSensor setPeripherals: nil];
        [mPeripherals removeAllObjects];
        [[self tvDevices] reloadData];
    }
    
    //    [self rotateScanButton];
    [NSTimer scheduledTimerWithTimeInterval:SCAN_TIMEOUT target:self selector:@selector(stopScan) userInfo:nil repeats:NO];
    if([mSensor findHMSoftPeripherals:SCAN_TIMEOUT] != 0) {
        [SVProgressHUD showErrorWithStatus:@"Veuillez activer le Bluetooth dans Réglages."];
    }
}


- (void)stopScan {
    sScanning = NO;
    [mRefreshDevices endRefreshing];
}






// ============================================================================
#pragma mark - BTSmartSensorDelegate
// ============================================================================
- (void)peripheralFound:(CBPeripheral *)peripheral {
    [mPeripherals addObject:peripheral];
    [[self tvDevices] reloadData];
    
    NSString * lastUUID = [Config getLastDeviceUUID];
    if(lastUUID != nil && [lastUUID isEqualToString:[[peripheral identifier] UUIDString]]) {
        // found last connected peripheral, connect !
        [self connectToPeripheral:peripheral];
    }
}
//- (void)serialGATTCharValueUpdated: (NSString *)UUID value: (NSData *)data {
//    NSLog(@"DATA RECEIVED FROM %@", UUID);
//    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", str);
//    [[self deviceDelegate] onDataReceived:str];
//}
- (void)dataReceived:(NSData *)aData from:(CBPeripheral *)aPeripheral {
    NSLog(@"Data from %@", [aPeripheral name]);
    NSString * str = [[NSString alloc] initWithData:aData encoding:NSASCIIStringEncoding];
    NSLog(@"%@", str);
    if([str hasPrefix:BLE_HEADER] && [str hasSuffix:BLE_TERMINATOR]) {
        // seems valid ble string, parse
        str = [str stringByReplacingOccurrencesOfString:BLE_HEADER withString:@""];
        str = [str stringByReplacingOccurrencesOfString:BLE_TERMINATOR withString:@""];
        [[self deviceDelegate] onNFCIDReceived:str];
    }
}

- (void)setConnect:(CBPeripheral *)aPeripheral {
    [Config setLastDeviceUUID:[[aPeripheral identifier] UUIDString]];
    NSLog(@"%@ connected !", [aPeripheral name]);
    [[self tvDevices] reloadData];
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Connecté à %@", [aPeripheral name]]];
    [[self deviceDelegate] didConnect];
}


- (void)setDisconnect:(CBPeripheral *)aPeripheral {
    [Config resetLastDeviceUUID];
    NSLog(@"%@ disconnected !", [aPeripheral name]);
    [[self tvDevices] reloadData];
    [SVProgressHUD showErrorWithStatus:@"Déconnecté."];
    [[self deviceDelegate] didDisconnect];
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
