//
//  ClientVC.h
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACUtils.h"
#import "RESideMenu.h"
#import "Config.h"
#import "ServerManager.h"
#import "SettingsVC.h"
#import "UIImageView+WebCache.h"
#import "GenericUserView.h"
#import "ConnectVC.h"

@interface ClientVC : UIViewController <ServerManagerDelegate, BLEManagerDelegate> {
    
}

//@property (retain, nonatomic) id<DeviceDataDelegate> deviceDelegate;

@end

