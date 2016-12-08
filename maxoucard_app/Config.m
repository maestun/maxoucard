//
//  Config.m
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "Config.h"


@implementation Config

USERPREF_IMPL(NSString *, Password, DEFAULT_PASS);
USERPREF_IMPL(NSString *, ServerURL, DEFAULT_BASE_URL);
USERPREF_IMPL(NSString *, LastDeviceUUID, @"LAST_UUID");

@end
