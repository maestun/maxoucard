//
//  ACUtils.h
//
//  Created by OHU on 01/07/2014.
//  Copyright (c) 2014 OHU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/time.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#include <unistd.h>
#include <netdb.h>
#import <UIKit/UIKit.h>


//#define ACLog(fmt, ...) do { if(AC_DEBUG_MODE) { NSLog(AC_DEBUG_PREFIX#fmt, ##__VA_ARGS__); }} while(0)
//#define ACErr(fmt, ...) do { if(AC_TRACE_ERRORS) { NSLog(AC_ERROR_PREFIX); NSLog(AC_DEBUG_PREFIX#fmt, ##__VA_ARGS__); }} while(0)

//Macros to declare a preference key (as a string)
#define USERPREF_STR_ROOT               @"USERPREF_"
#define DECL_USERPREF_STR(n)            NSString * const n = USERPREF_STR_ROOT#n

//Macros to build the getters (prototype and implementation)
#define GET_USERPREF_DECL(t, n)         +(t) get##n
#define GET_USERPREF_IMPL(t, n, v)      GET_USERPREF_DECL(t, n) { \
t const USERPREF_DEFAULT_##n = v; \
NSUserDefaults * p = [NSUserDefaults standardUserDefaults]; \
t ret = [p objectForKey:USERPREF_STR_ROOT#n]; \
return (ret == nil) ? USERPREF_DEFAULT_##n : ret; \
}

//Macros to build the setters (prototype and implementation)
#define SET_USERPREF_DECL(t, n)         +(void) set##n:(t)v
#define SET_USERPREF_IMPL(t, n)         SET_USERPREF_DECL(t, n) { \
NSUserDefaults * p = [NSUserDefaults standardUserDefaults]; \
[p setValue:v forKey:n]; \
[p synchronize]; \
}

//
#define RESET_USERPREF_DECL(n)          +(void) reset##n
#define RESET_USERPREF_IMPL(n, v)       RESET_USERPREF_DECL(n) { \
NSUserDefaults * p = [NSUserDefaults standardUserDefaults]; \
[p setValue:v forKey:n]; \
[p synchronize]; \
}

//Macro to build all the declarations for a given preference key
#define USERPREF_DECL(t, n)             SET_USERPREF_DECL(t, n); \
GET_USERPREF_DECL(t, n); \
RESET_USERPREF_DECL(n)

//Macro to build all the implementations for a given preference key (t : type, n : name, v : default value)
#define USERPREF_IMPL(t, n, v)          DECL_USERPREF_STR(n); \
SET_USERPREF_IMPL(t, n) \
GET_USERPREF_IMPL(t, n, v) \
RESET_USERPREF_IMPL(n, v)

//How to declare:
//in MY_CLASS.h: USERPREF_DECL(NSNumber *, MeasureTime);

//How to implement:
//in MY_CLASS.m: USERPREF_IMPL(NSNumber *, MeasureTime, [NSNumber numberWithInt:2]);

//How to set/get: [MY_CLASS getMeasureTime] and [MY_CLASS setMeasureTime]

#define STRINGIFY(val)                @#val


#define CELL_ID(c)                              [NSString stringWithFormat:@"id%@", NSStringFromClass([c class])]
#define REGISTER_TABLE_CELL_CLASS(t, c)         [t registerClass:[c class] forCellReuseIdentifier:CELL_ID(c)]
#define REGISTER_COLLECTION_CELL_CLASS(t, c)    [t registerClass:[c class] forCellWithReuseIdentifier:CELL_ID(c)]


#define INT2F(x)                    ((x) * (1.0f / 255))
#define RGBA(r, g, b, a)            [UIColor colorWithRed:(INT2F(r)) green:(INT2F(g)) blue:(INT2F(b)) alpha:(INT2F(a))]
#define ARGB(a, r, g, b)            [UIColor colorWithRed:(INT2F(r)) green:(INT2F(g)) blue:(INT2F(b)) alpha:(INT2F(a))]
#define RGBA_UINT32(c)              [UIColor colorWithRed:(INT2F((c & 0xFF000000) >> 24)) green:(INT2F((c & 0xFF0000) >> 16)) blue:(INT2F((c & 0xFF00) >> 8)) alpha:(INT2F(c & 0xFF))]
#define ARGB_UINT32(c)              [UIColor colorWithRed:(INT2F((c & 0xFF0000) >> 16)) green:(INT2F((c & 0xFF00) >> 8)) blue:(INT2F(c & 0xFF)) alpha:(INT2F((c & 0xFF000000) >> 24))]

#define COLOR_CLEAR                 [UIColor clearColor]
#define LOCALIZE(key)               NSLocalizedString(key, key)
#define DEGREES_TO_RADIANS(angle)   ((angle) / 180.0 * M_PI)

#define LOREM_IPSUM                 @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum"

#define NULL_ID                     -1

@interface ACUtils : NSObject
+ (BOOL)isNetworkAvailable;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIColor *)getIntermediateColor:(float) alpha colorMin:(UIColor *)c1 colorMax:(UIColor*)c2;
+ (uint32_t)UIColor2RGBA:(UIColor*)aColor;
+ (void)localize:(UIView *)aView;
+ (int64_t)getTick;
+ (BOOL)isPad;
+ (NSString *)upperStringOfFirstWords:(NSString *)aString;
+ (NSString *)compressNumber:(int)aValue;
+ (NSString *)randomAlphaString:(int)aLength;
+ (NSString *)hmacsha1:(NSString *)aData secret:(NSString *)aKey;
+ (NSString *)sha1:(NSString *)aInput;
+ (NSString *)sha1data:(NSData *)aInput;
+ (CGSize)getRotatedViewControllerSize:(UIViewController *)aViewController;
+ (UIImage *)tintedImageWithColor:(UIColor *)tintColor image:(UIImage *)image;
+ (UIImage *)squareImageFromImage:(UIImage *)aImage;
+ (BOOL)isEmailValid:(NSString *)aEmail;
+ (NSString *)md5:(NSString *)aString;
+ (UIImage *)overlayImage:(UIImage *)source withColor:(UIColor *)color;
//+ (UIColor *) colorFromHexString:(NSString *)hexString;
+ (UIColor *)colorFromARGBString:(NSString *)aARGB;


// UImage of a solid color and size. Good for placeholders.
+ (UIImage *)imageFromColor:(UIColor *)color andSize:(CGSize)size;
+ (UIImage *) imageWithView:(UIView *)view;
// create a 1x1 image
+ (UIImage *)imageFromColor:(UIColor *)color;
// vertical linear gradient at the given frame from topColor to bottomColor
+ (CAGradientLayer *)gradientWithFrame:(CGRect)frame fromColor:(UIColor *)topColor toColor:(UIColor *)bottomColor;
// darkens a UIColor by a given amount
+ (UIColor *)darkenColor:(UIColor *)oldColor percentOfOriginal:(float)amount;
+ (UIColor *)darkenCGColorRef:(CGColorRef)oldColor percentOfOriginal:(float)amount;
// lightens a UIColor by a given amount
+ (UIColor *)lightenColor:(UIColor *)oldColor byPercentage:(float)amount;
+ (UIColor *)lightenCGColor:(CGColorRef)oldColor byPercentage:(float)amount;
+ (UIColor*)pixelColorInImage:(UIImage*)image atX:(int)x atY:(int)y;
+ (UIColor *)averageColor:(UIImage *)aImage;

+(NSDictionary*)mainColoursInImage:(UIImage *)image detail:(int)detail;

+ (BOOL)isDarkColor:(UIColor *)aColor;
@end
