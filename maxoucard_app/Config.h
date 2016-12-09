//
//  Config.h
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#ifndef _CONFIG_H_
#define _CONFIG_H_

#import <RESideMenu/RESideMenu.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <ChameleonFramework/Chameleon.h>
#import <AFNetworking/AFNetworking.h>
#import "ACUtils.h"


// ==========================================================================================
// STUFFZ : here be stuffz :p
// ==========================================================================================
#define DEFAULT_PASS                            @"skymaxx"
#define DEFAULT_BASE_URL                        @"http://192.168.1.10:3000"
#define BLE_HEADER                              @"NFC;"
#define BLE_TERMINATOR                          @"."


// ==========================================================================================
// COLORS : modify these colors if needed, beware of bad taste !!!
// ==========================================================================================
#define APP_COLOR                               FlatBlue
#define TEXT_COLOR_WHITE                        FlatWhite
#define TEXT_COLOR_BLACK                        FlatBlack
#define BACK_COLOR                              FlatWhite


// ==========================================================================================
// FONTS : modify these fonts if needed, beware of the width !!!
// ==========================================================================================
#define __FONT_BASE                             @"AvenirNext"
#define __FONT_REGULAR                          @"-Regular"
#define __FONT_BOLD                             @"-DemiBold"
#define __FONT_LITE                             @"-UltraLight"
#define FONT_SZ_XLARGE                          26
#define FONT_SZ_LARGE                           20
#define FONT_SZ_MEDIUM                          16
#define FONT_SZ_SMALL                           12
#define FONT_SZ_XSMALL                          10
#define FONT(sz)                                [UIFont fontWithName:[NSString stringWithFormat:@"%@%@", __FONT_BASE, __FONT_REGULAR] size:(sz)]
#define FONT_BOLD(sz)                           [UIFont fontWithName:[NSString stringWithFormat:@"%@%@", __FONT_BASE, __FONT_BOLD] size:(sz)]
#define FONT_LITE(sz)                           [UIFont fontWithName:[NSString stringWithFormat:@"%@%@", __FONT_BASE, __FONT_LITE] size:(sz)]


@interface Config : NSObject

USERPREF_DECL(NSString *, Password);
USERPREF_DECL(NSString *, ServerURL);
USERPREF_DECL(NSString *, LastDeviceUUID);

@end


#endif
