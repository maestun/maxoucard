//
//  GenericUser.h
//  maxoucard_app
//
//  Created by Olivier on 09/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericUser : NSObject

@property (weak, nonatomic) NSString *ident;
@property (weak, nonatomic) NSString *title;
@property (weak, nonatomic) NSString *fname;
@property (weak, nonatomic) NSString *lname;
@property (weak, nonatomic) NSString *bigpicURL;
@property (weak, nonatomic) NSString *midpicURL;
@property (weak, nonatomic) NSString *thumbURL;
@property (weak, nonatomic) NSString *linkedin;
@property (weak, nonatomic) NSString *email;
@property (weak, nonatomic) NSString *nfc;
@property (weak, nonatomic) NSString *phone;



@end
