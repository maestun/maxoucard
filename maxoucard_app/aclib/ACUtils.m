//
//  ACUtils.m
//  changidemo
//
//  Created by OHU on 01/07/2014.
//  Copyright (c) 2014 OHU. All rights reserved.
//

#import "ACUtils.h"

@implementation ACUtils

// Mod of @horsejockey's method:
// http://stackoverflow.com/a/19413033



+(BOOL)isPad {
#ifdef UI_USER_INTERFACE_IDIOM
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
    return NO;
}

+ (BOOL)isDarkColor:(UIColor *)aColor {
    const CGFloat *componentColors = CGColorGetComponents(aColor.CGColor);
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    return (colorBrightness < 0.5);
}


+ (UIColor *)getIntermediateColor:(float) alpha colorMin:(UIColor *)c1 colorMax:(UIColor*)c2 {
    
    alpha = MIN( 1.f, MAX( 0.f, alpha ) );
    float beta = 1.f - alpha;
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [c1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [c2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    CGFloat r = r1 * beta + r2 * alpha;
    CGFloat g = g1 * beta + g2 * alpha;
    CGFloat b = b1 * beta + b2 * alpha;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}

+ (UIImage *) imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, /* cell.isOpaque */NO, 0.0f); // OHU
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(uint32_t)UIColor2RGBA:(UIColor*)aColor {
    
    CGFloat r, g, b, a;
    [aColor getRed:&r green:&g blue:&b alpha:&a];
    
    int ir = (int)(r * 255);
    int ig = (int)(g * 255);
    int ib = (int)(b * 255);
    int ia = (int)(a * 255);
    
    return (ia << 24) + (ib << 16) + (ig << 8) + ir;
}

+ (BOOL)isEmailValid:(NSString *)aEmail {
    NSError * err = nil;
    NSString *expression = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"; // Edited: added ^ and $
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&err];
    NSTextCheckingResult *match = [regex firstMatchInString:aEmail options:0 range:NSMakeRange(0, [aEmail length])];
//    NSUInteger loc_at = [aEmail rangeOfString:@"@"].location;
//    NSUInteger loc_pt = [aEmail rangeOfString:@"."].location;
    return match != nil;//(loc_at != NSNotFound && loc_at < loc_pt);
}

+ (UIImage *)squareImageFromImage:(UIImage *)aImage {
    // resize
    UIImage * ret = nil;
    
    CGFloat IMG_SZ_W = [aImage size].width;
    CGFloat IMG_SZ_H = [aImage size].height;
    
    UIGraphicsBeginImageContext(CGSizeMake(IMG_SZ_W, IMG_SZ_H));
    
//    [aImage drawInRect: CGRectMake(0, 0, IMG_SZ_W, IMG_SZ_H)];
////    UIImage * smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGRect cropRect = CGRectMake(IMG_SZ_W > IMG_SZ_H ? (IMG_SZ_W - IMG_SZ_H) / 2 : 0,
                                 IMG_SZ_H > IMG_SZ_W ? (IMG_SZ_H - IMG_SZ_W) / 2 : 0,
                                 MIN(IMG_SZ_W, IMG_SZ_H),
                                 MIN(IMG_SZ_W, IMG_SZ_H));
    CGImageRef imageRef = CGImageCreateWithImageInRect([aImage CGImage], cropRect);
    
    ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return  ret;
}

//+ (UIImage *)replacePixelColor:(UIColor *)aSourceColor withColor:(UIColor *)aDestinationColor inImage:(UIImage *)aImage {
//
////    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 1.0);
////    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
////    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
////    
////    
//
//    CGImageRef rawImageRef = aImage.CGImage;
//    const float colorMasking[6] = {255, 255, 255, 255, 255, 255};
//    UIGraphicsBeginImageContext(aImage.size);
//    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
//    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, aImage.size.height);
//    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
//
//    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, aImage.size.width, aImage.size.height), maskedImageRef);
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    CGImageRelease(maskedImageRef);
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}

+ (UIImage *)overlayImage:(UIImage *)source withColor:(UIColor *)color {
    
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color setFill];
    
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}
+ (UIImage *)tintedImageWithColor:(UIColor *)tintColor image:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}


+(BOOL)isNetworkAvailable {
    BOOL network_ok = YES;
#if TARGET_IPHONE_SIMULATOR
#else
    struct addrinfo * res = NULL;
    int s = getaddrinfo("google.com", NULL, NULL, &res);
    network_ok = (s == 0 && res != NULL);
    freeaddrinfo(res);
#endif
    return network_ok;
}


+ (CGSize)getRotatedViewControllerSize:(UIViewController *)aViewController {
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(aViewController.interfaceOrientation);
    
    float max = MAX(aViewController.view.bounds.size.width, aViewController.view.bounds.size.height);
    float min = MIN(aViewController.view.bounds.size.width, aViewController.view.bounds.size.height);
    
    return (isPortrait ?
            CGSizeMake(min, max) :
            CGSizeMake(max, min));
}


+ (NSString *)upperStringOfFirstWords:(NSString *)aString {
    NSMutableString *result = [aString mutableCopy];
    [result enumerateSubstringsInRange:NSMakeRange(0, [result length])
                           options:NSStringEnumerationByWords
                        usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                            [result replaceCharactersInRange:NSMakeRange(substringRange.location, 1)
                                                  withString:[[substring substringToIndex:1] uppercaseString]];
                        }];
    return result;
}

+ (NSString *)compressNumber:(int)aValue {
    NSString * ret = @"";
    if(aValue >= 1000) {
        if(aValue >= 1000000) {
            if(aValue >= 1000000000) {
                ret = [NSString stringWithFormat:@"%d MD", (aValue / 1000000000)];
            }
            else {
                ret = [NSString stringWithFormat:@"%d M", (aValue / 1000000)];
            }
        }
        else {
            ret = [NSString stringWithFormat:@"%d K", (aValue / 1000)];
        }
    }
    else {
        ret = [NSString stringWithFormat:@"%d ", aValue];
    }
    
    return ret;
}

+ (void)localize:(UIView *)aView {
    if ([aView class] == [UILabel class]) {
        UILabel * ret = (UILabel *)aView;
        [ret setText:LOCALIZE([ret text])];
    }
    else if([aView class] == [UIButton class]) {
        UIButton * ret = (UIButton *)aView;
        [ret setTitle:LOCALIZE([[ret titleLabel] text]) forState:UIControlStateNormal];
    }
    else if([aView class] == [UITextField class] || [aView class] == [UISearchBar class]) {
        UITextField * ret = (UITextField *)aView;
        [ret setPlaceholder:LOCALIZE([ret placeholder])];
    }
    else if([aView class] == [UISegmentedControl class]) {
        UISegmentedControl * ret = (UISegmentedControl *)aView;
        for(int idx = 0; idx < [ret numberOfSegments]; idx++) {
            [ret setTitle:LOCALIZE([ret titleForSegmentAtIndex:idx]) forSegmentAtIndex:idx];
        }
    }
}

+ (int64_t)getTick {
    struct timeval time;
    gettimeofday(&time, NULL);
    
    int64_t milliSeconds = (int64_t)((int64_t)time.tv_sec * (int64_t)1000);
    int64_t returnValue = milliSeconds + (time.tv_usec / 1000);
    
    return returnValue;
}


+ (NSString *)randomAlphaString:(int)aLength {
    NSString * alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    
    NSMutableString * s = [NSMutableString stringWithCapacity:aLength];
    for (NSUInteger i = 0U; i < aLength; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}


+ (NSString *)hmacsha1:(NSString *)aData secret:(NSString *)aKey {
    
    const char * cKey  = [aKey cStringUsingEncoding:NSASCIIStringEncoding];
    const char * cData = [aData cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    
    return output;
}


+ (NSString *)sha1:(NSString *)aInput {
    
    const char * cstr = [aInput cStringUsingEncoding:NSUTF8StringEncoding];
    NSData * data = [NSData dataWithBytes:cstr length:aInput.length];
    return [ACUtils sha1data:data];
}


+ (NSString *)sha1data:(NSData *)aInput {
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(aInput.bytes, (uint32_t)aInput.length, digest);
    
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSString *)md5:(NSString *)aString
{
    const char* cStr = [aString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    static const char HexEncodeChars[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    char *resultData = malloc(CC_MD5_DIGEST_LENGTH * 2 + 1);
    
    for (uint index = 0; index < CC_MD5_DIGEST_LENGTH; index++) {
        resultData[index * 2] = HexEncodeChars[(result[index] >> 4)];
        resultData[index * 2 + 1] = HexEncodeChars[(result[index] % 0x10)];
    }
    resultData[CC_MD5_DIGEST_LENGTH * 2] = 0;
    
    NSString *resultString = [NSString stringWithCString:resultData encoding:NSASCIIStringEncoding];
    free(resultData);
    
    return resultString;
}

+ (CAGradientLayer *)gradientWithFrame:(CGRect)frame fromColor:(UIColor *)topColor toColor:(UIColor *)bottomColor
{
    CAGradientLayer *shadowGradient = [CAGradientLayer layer];
    shadowGradient.frame = frame;
    shadowGradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
    return shadowGradient;
}

+ (UIColor *)darkenColor:(UIColor *)oldColor percentOfOriginal:(float)amount {
    return [ACUtils darkenCGColorRef:oldColor.CGColor percentOfOriginal:amount];
}


+ (UIColor *)darkenCGColorRef:(CGColorRef)oldColor percentOfOriginal:(float)amount
{
    float percentage      = amount / 100.0;
    size_t   totalComponents = CGColorGetNumberOfComponents(oldColor);
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(oldColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0]*percentage;
        newComponents[1] = oldComponents[0]*percentage;
        newComponents[2] = oldComponents[0]*percentage;
        newComponents[3] = oldComponents[1];
    } else {
        newComponents[0] = oldComponents[0]*percentage;
        newComponents[1] = oldComponents[1]*percentage;
        newComponents[2] = oldComponents[2]*percentage;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}



+ (UIColor *)lightenColor:(UIColor *)oldColor byPercentage:(float)amount
{
    return [ACUtils lightenCGColor:oldColor.CGColor byPercentage:amount];
}

+ (UIColor *)lightenCGColor:(CGColorRef)oldColor byPercentage:(float)amount {

    float percentage      = amount / 100.0;
    size_t   totalComponents = CGColorGetNumberOfComponents(oldColor);
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(oldColor);
    CGFloat newComponents[4];
    
    // FIXME: Clean this SHITE up
    if (isGreyscale) {
        newComponents[0] = oldComponents[0]*percentage + oldComponents[0] > 1.0 ? 1.0 : oldComponents[0]*percentage + oldComponents[0];
        newComponents[1] = oldComponents[0]*percentage + oldComponents[0] > 1.0 ? 1.0 : oldComponents[0]*percentage + oldComponents[0];
        newComponents[2] = oldComponents[0]*percentage + oldComponents[0] > 1.0 ? 1.0 : oldComponents[0]*percentage + oldComponents[0];
        newComponents[3] = oldComponents[0]*percentage + oldComponents[1] > 1.0 ? 1.0 : oldComponents[1]*percentage + oldComponents[1];
    } else {
        newComponents[0] = oldComponents[0]*percentage + oldComponents[0] > 1.0 ? 1.0 : oldComponents[0]*percentage + oldComponents[0];
        newComponents[1] = oldComponents[1]*percentage + oldComponents[1] > 1.0 ? 1.0 : oldComponents[0]*percentage + oldComponents[1];
        newComponents[2] = oldComponents[2]*percentage + oldComponents[2] > 1.0 ? 1.0 : oldComponents[0]*percentage + oldComponents[2];
        newComponents[3] = oldComponents[3]*percentage + oldComponents[3] > 1.0 ? 1.0 : oldComponents[0]*percentage + oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}


+ (UIColor*)pixelColorInImage:(UIImage*)image atX:(int)x atY:(int)y {
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int pixelInfo = ((image.size.width  * y) + x ) * 4; // 4 bytes per pixel
    
    UInt8 red   = data[pixelInfo + 0];
    UInt8 green = data[pixelInfo + 1];
    UInt8 blue  = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    CFRelease(pixelData);
    
    return [UIColor colorWithRed:red/255.0f
                           green:green/255.0f
                            blue:blue/255.0f
                           alpha:alpha/255.0f];
}


+ (UIColor *)averageColor:(UIImage *)aImage {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), aImage.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}













+(NSDictionary*)mainColoursInImage:(UIImage *)image detail:(int)detail {
    
    //1. determine detail vars (0==low,1==default,2==high)
    //default detail
    float dimension = 10;
    float flexibility = 2;
    float range = 60;
    
    //low detail
    if (detail==0){
        dimension = 4;
        flexibility = 1;
        range = 100;
        
        //high detail (patience!)
    } else if (detail==2){
        dimension = 100;
        flexibility = 10;
        range = 20;
    }
    
    //2. determine the colours in the image
    NSMutableArray * colours = [NSMutableArray new];
    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(dimension * dimension * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * dimension;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, dimension, dimension, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, dimension, dimension), imageRef);
    CGContextRelease(context);
    
    float x = 0;
    float y = 0;
    for (int n = 0; n<(dimension*dimension); n++){
        
        int index = (bytesPerRow * y) + x * bytesPerPixel;
        int red   = rawData[index];
        int green = rawData[index + 1];
        int blue  = rawData[index + 2];
        int alpha = rawData[index + 3];
        NSArray * a = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",red],[NSString stringWithFormat:@"%i",green],[NSString stringWithFormat:@"%i",blue],[NSString stringWithFormat:@"%i",alpha], nil];
        [colours addObject:a];
        
        y++;
        if (y==dimension){
            y=0;
            x++;
        }
    }
    free(rawData);
    
    //3. add some colour flexibility (adds more colours either side of the colours in the image)
    NSArray * copyColours = [NSArray arrayWithArray:colours];
    NSMutableArray * flexibleColours = [NSMutableArray new];
    
    float flexFactor = flexibility * 2 + 1;
    float factor = flexFactor * flexFactor * 3; //(r,g,b) == *3
    for (int n = 0; n<(dimension * dimension); n++){
        
        NSArray * pixelColours = copyColours[n];
        NSMutableArray * reds = [NSMutableArray new];
        NSMutableArray * greens = [NSMutableArray new];
        NSMutableArray * blues = [NSMutableArray new];
        
        for (int p = 0; p<3; p++){
            
            NSString * rgbStr = pixelColours[p];
            int rgb = [rgbStr intValue];
            
            for (int f = -flexibility; f<flexibility+1; f++){
                int newRGB = rgb+f;
                if (newRGB<0){
                    newRGB = 0;
                }
                if (p==0){
                    [reds addObject:[NSString stringWithFormat:@"%i",newRGB]];
                } else if (p==1){
                    [greens addObject:[NSString stringWithFormat:@"%i",newRGB]];
                } else if (p==2){
                    [blues addObject:[NSString stringWithFormat:@"%i",newRGB]];
                }
            }
        }
        
        int r = 0;
        int g = 0;
        int b = 0;
        for (int k = 0; k<factor; k++){
            
            int red = [reds[r] intValue];
            int green = [greens[g] intValue];
            int blue = [blues[b] intValue];
            
            NSString * rgbString = [NSString stringWithFormat:@"%i,%i,%i",red,green,blue];
            [flexibleColours addObject:rgbString];
            
            b++;
            if (b==flexFactor){ b=0; g++; }
            if (g==flexFactor){ g=0; r++; }
        }
    }
    
    //4. distinguish the colours
    //orders the flexible colours by their occurrence
    //then keeps them if they are sufficiently disimilar
    
    NSMutableDictionary * colourCounter = [NSMutableDictionary new];
    
    //count the occurences in the array
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:flexibleColours];
    for (NSString *item in countedSet) {
        NSUInteger count = [countedSet countForObject:item];
        [colourCounter setValue:[NSNumber numberWithInteger:count] forKey:item];
    }
    
    //sort keys highest occurrence to lowest
    NSArray *orderedKeys = [colourCounter keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];
    
    //checks if the colour is similar to another one already included
    NSMutableArray * ranges = [NSMutableArray new];
    for (NSString * key in orderedKeys){
        NSArray * rgb = [key componentsSeparatedByString:@","];
        int r = [rgb[0] intValue];
        int g = [rgb[1] intValue];
        int b = [rgb[2] intValue];
        bool exclude = false;
        for (NSString * ranged_key in ranges){
            NSArray * ranged_rgb = [ranged_key componentsSeparatedByString:@","];
            
            int ranged_r = [ranged_rgb[0] intValue];
            int ranged_g = [ranged_rgb[1] intValue];
            int ranged_b = [ranged_rgb[2] intValue];
            
            if (r>= ranged_r-range && r<= ranged_r+range){
                if (g>= ranged_g-range && g<= ranged_g+range){
                    if (b>= ranged_b-range && b<= ranged_b+range){
                        exclude = true;
                    }
                }
            }
        }
        
        if (!exclude){ [ranges addObject:key]; }
    }
    
    //return ranges array here if you just want the ordered colours high to low
    NSMutableArray * colourArray = [NSMutableArray new];
    for (NSString * key in ranges){
        NSArray * rgb = [key componentsSeparatedByString:@","];
        float r = [rgb[0] floatValue];
        float g = [rgb[1] floatValue];
        float b = [rgb[2] floatValue];
        UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
        [colourArray addObject:colour];
    }
    
    //if you just want an array of images of most common to least, return here
    //return [NSDictionary dictionaryWithObject:colourArray forKey:@"colours"];
    
    
    //if you want percentages to colours continue below
    NSMutableDictionary * temp = [NSMutableDictionary new];
    float totalCount = 0.0f;
    for (NSString * rangeKey in ranges){
        NSNumber * count = colourCounter[rangeKey];
        totalCount += [count intValue];
        temp[rangeKey]=count;
    }
    
    //set percentages
    NSMutableDictionary * colourDictionary = [NSMutableDictionary new];
    for (NSString * key in temp){
        float count = [temp[key] floatValue];
        float percentage = count/totalCount;
        NSArray * rgb = [key componentsSeparatedByString:@","];
        float r = [rgb[0] floatValue];
        float g = [rgb[1] floatValue];
        float b = [rgb[2] floatValue];
        UIColor * colour = [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0f];
        colourDictionary[colour]=[NSNumber numberWithFloat:percentage];
    }
    
    return colourDictionary;
    
}

+(UIImage *)imageFromColor:(UIColor *)color andSize:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageFromColor:(UIColor *)color
{
    return [ACUtils imageFromColor:color andSize:CGSizeMake(1, 1)];
}


+ (UIColor *)colorFromARGBString:(NSString *)aARGB {
    unsigned int a, r, g, b;
    [[NSScanner scannerWithString:[aARGB substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&a];
    [[NSScanner scannerWithString:[aARGB substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&r];
    [[NSScanner scannerWithString:[aARGB substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&g];
    [[NSScanner scannerWithString:[aARGB substringWithRange:NSMakeRange(6, 2)]] scanHexInt:&b];
    return ARGB(a, r, g, b);
}


//+ (UIColor *) colorFromHexString:(NSString *)hexString {
//    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
//    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"0x" withString:@""];
//    
//    if([cleanString length] == 3) {
//        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
//                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
//                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
//                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
//    }
//    if([cleanString length] == 6) {
//        cleanString = [cleanString stringByAppendingString:@"ff"];
//    }
//    
//    unsigned int baseValue;
//    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
//    
//    float red = ((baseValue >> 24) & 0xFF)/255.0f;
//    float green = ((baseValue >> 16) & 0xFF)/255.0f;
//    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
//    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
//    
//    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
//}


@end
