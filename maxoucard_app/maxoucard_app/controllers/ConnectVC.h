//
//  ConnectVC.h
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericUserView.h"
#import "ServerManager.h"
#import "BLEManager.h"

@interface ConnectVC : UIViewController <BLEManagerDelegate, ServerManagerDelegate>
@property (weak, nonatomic) IBOutlet GenericUserView *gvLeft;
@property (weak, nonatomic) IBOutlet GenericUserView *gvRight;

@property (weak, nonatomic) GenericUser *userRight;
@property (weak, nonatomic) GenericUser *userLeft;
@end
