//
//  SettingsVC.h
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SerialGATT.h"
#import "Config.h"
#import "ServerManager.h"

@protocol DeviceDataDelegate <NSObject>
- (void)onDataReceived:(NSString *)aString;
@end


@interface SettingsVC : UIViewController <ServerManagerDelegate, BTSmartSensorDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray * mPeripherals;
    NSMutableArray * mUsers;
    SerialGATT * mSensor;
//    NSString * mLastUUID;
    UIRefreshControl * mRefresh;
}
@property (retain, nonatomic) id<DeviceDataDelegate> deviceDelegate;

@end
