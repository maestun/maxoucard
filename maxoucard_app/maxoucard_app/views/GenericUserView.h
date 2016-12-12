//
//  GenericUserView.h
//  maxoucard_app
//
//  Created by Olivier on 09/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "GenericUser.h"

@interface GenericUserView : UIView
@property (strong, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UIImageView *ivProfile;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbWelcome;

@property BOOL isPopulated;

@property (retain, nonatomic, readonly) GenericUser *user;

- (void)setUser:(GenericUser *)aUser welcome:(NSString *)aWelcome;

@end
