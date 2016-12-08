//
//  ServerManager.h
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"

@protocol ServerManagerDelegate <NSObject>
- (void)onTestServer:(NSError *)aError version:(NSString *)aVersion;

@end

@interface ServerManager : NSObject

+ (void)testServer:(NSString *)aURL delegate:(id<ServerManagerDelegate>)aDelegate ;

@end
