//
//  ConnectVC.h
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericUserView.h"
#import "SettingsVC.h"

@interface ConnectVC : UIViewController <DeviceDataDelegate, ServerManagerDelegate>
@property (weak, nonatomic) IBOutlet GenericUserView *gvLeft;
@property (weak, nonatomic) IBOutlet GenericUserView *gvRight;

@property (weak, nonatomic) GenericUser *userRight;
@property (weak, nonatomic) GenericUser *userLeft;
@end
