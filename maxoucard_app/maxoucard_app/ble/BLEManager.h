//
//  BLEManager.h
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SerialGATT.h"
#import "Config.h"
#import "../../../maxoucard_ble/ble_commands.h"

@class BLEManager;

@protocol BLEManagerDelegate <NSObject>
- (void)ble:(BLEManager *)aManager didReceiveNFCID:(NSString *)aNFCID;
- (void)ble:(BLEManager *)aManager didConnectToPeripheral:(CBPeripheral *)aPeripheral;
- (void)ble:(BLEManager *)aManager didFindPeripheral:(CBPeripheral *)aPeripheral;
- (void)ble:(BLEManager *)aManager didDisconnectfromPeripheral:(CBPeripheral *)aPeripheral;
- (void)bleDidStartScan:(BLEManager *)aManager;
- (void)bleDidStopScan:(BLEManager *)aManager;
- (void)ble:(BLEManager *)aManager error:(NSError *)aError;
@end

@interface BLEManager : NSObject <BTSmartSensorDelegate> {
}
- (void)registerDelegate:(id<BLEManagerDelegate>)aDelegate;
+ (BLEManager *)instance;
- (void)startScan;
- (void)connectToPeripheral:(CBPeripheral *)aPeripheral;
- (NSMutableArray *)peripherals;
//@property (strong, nonatomic) NSMutableArray * peripherals;
@end
