//
//  BLEManager.m
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "BLEManager.h"

#define SCAN_TIMEOUT            5


@interface BLEManager ()
@property (retain, nonatomic) NSMutableArray * delegates;
@property (retain, nonatomic) SerialGATT * sensor;
@property BOOL connected;
@end


@implementation BLEManager

static BLEManager * sInstance = nil;

+ (BLEManager *)instance {
    if(sInstance == nil) {
        sInstance = [[BLEManager alloc] init];
    }
    return sInstance;
}


- (instancetype)init {
    self = [super init];
    if(self) {
        [self setSensor:[[SerialGATT alloc] init]];
        [[self sensor] setup];
        [[self sensor] setDelegate:self];
        [self setDelegates:[NSMutableArray array]];
        
//        [self setPeripherals: [[NSMutableArray alloc] init]];
    }
    return self;
}



- (void)registerDelegate:(id<BLEManagerDelegate>)aDelegate {
    if([[self delegates] indexOfObject:aDelegate] == NSNotFound) {
        [[self delegates] addObject:aDelegate];
    }
}


// ============================================================================
#pragma mark - BLE Connectivity
// ============================================================================
- (void)connectToPeripheral:(CBPeripheral *)aPeripheral {
    
    // stop scanning
//    [self stopScan];
    
    // disconnect from current peripheral
    if([[self sensor] activePeripheral]) {
        [[self sensor] disconnect:[[self sensor] activePeripheral]];
    }
    
    // connect to peripheral
    [[self sensor] connect:aPeripheral];
    [[self sensor] setActivePeripheral:aPeripheral];
    
    
    for(id<BLEManagerDelegate> d in [self delegates]) {
        if([d respondsToSelector:@selector(ble:didConnectToPeripheral:)]) {
            [d ble:self didConnectToPeripheral:aPeripheral];
        }
    }

    
    //[[self tvDevices] reloadData];
}


- (void)startScan {
    // notify
    for(id<BLEManagerDelegate> d in [self delegates]) {
        if([d respondsToSelector:@selector(bleDidStartScan:)]) {
            [d bleDidStartScan:self];
        }
    }
    
    // disconnect from current connected peripheral
    if ([[self sensor] activePeripheral]) {
        if ([[[self sensor] activePeripheral] state] == CBPeripheralStateConnected) {
            [[[self sensor] manager] cancelPeripheralConnection:[[self sensor] activePeripheral]];
            [[self sensor] setActivePeripheral:nil];
        }
    }
    
    // remove peripheral cache from sensor
    [[[self sensor] peripherals] removeAllObjects];
    
    if([[self sensor] findHMSoftPeripherals:SCAN_TIMEOUT] != 0) {
        NSError * err = [NSError errorWithDomain:@"BLE not initialized" code:-1 userInfo:nil];
        for(id<BLEManagerDelegate> d in [self delegates]) {
            if([d respondsToSelector:@selector(ble:error:)]) {
                [d ble:self error:err];
            }
        }
    }
}




- (NSMutableArray *)peripherals {
    return [[self sensor] peripherals];
}




// ============================================================================
#pragma mark - BTSmartSensorDelegate
// ============================================================================
- (void)scanStop {
    for(id<BLEManagerDelegate> d in [self delegates]) {
        if([d respondsToSelector:@selector(bleDidStopScan:)]) {
            [d bleDidStopScan:self];
        }
    }
}

- (void)peripheralFound:(CBPeripheral *)peripheral {
//    [[self peripherals] addObject:peripheral];
//    [[self tvDevices] reloadData];
    
    NSString * lastUUID = [Config getLastDeviceUUID];
    if(lastUUID != nil && [lastUUID isEqualToString:[[peripheral identifier] UUIDString]]) {
        // found last connected peripheral, connect !
        [self connectToPeripheral:peripheral];
    }
    else {
        
    }
    
    for(id<BLEManagerDelegate> d in [self delegates]) {
        if([d respondsToSelector:@selector(ble:didFindPeripheral:)]) {
            [d ble:self didFindPeripheral:peripheral];
        }
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
//        [[self deviceDelegate] onNFCIDReceived:str];
        for(id<BLEManagerDelegate> d in [self delegates]) {
            if([d respondsToSelector:@selector(ble:didReceiveNFCID:)]) {
                [d ble:self didReceiveNFCID:str];
            }
        }

    }
}

- (void)setConnect:(CBPeripheral *)aPeripheral {
    [Config setLastDeviceUUID:[[aPeripheral identifier] UUIDString]];
    NSLog(@"%@ connected !", [aPeripheral name]);
//    [[self tvDevices] reloadData];
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Connecté à %@", [aPeripheral name]]];
//    [[self deviceDelegate] didConnect];
    
    for(id<BLEManagerDelegate> d in [self delegates]) {
        if([d respondsToSelector:@selector(ble:didDisconnectfromPeripheral:)]) {
            [d ble:self didConnectToPeripheral:aPeripheral];
        }
    }
}


- (void)setDisconnect:(CBPeripheral *)aPeripheral {
    [Config resetLastDeviceUUID];
    NSLog(@"%@ disconnected !", [aPeripheral name]);
//    [[self tvDevices] reloadData];
//    [SVProgressHUD showErrorWithStatus:@"Déconnecté."];
//    [[self deviceDelegate] didDisconnect];
    for(id<BLEManagerDelegate> d in [self delegates]) {
        if([d respondsToSelector:@selector(ble:didDisconnectfromPeripheral:)]) {
            [d ble:self didDisconnectfromPeripheral:aPeripheral];
        }
    }
}










@end
