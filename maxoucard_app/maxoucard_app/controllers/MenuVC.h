//
//  MenuVC.h
//  maxoucard_app
//
//  Created by Olivier on 11/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketManager.h"
#import "ServerManager.h"

@interface MenuVC : UIViewController <SocketManagerDelegate, ServerManagerDelegate>

@end
