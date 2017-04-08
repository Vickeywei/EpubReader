//
//  UIColor+Hex.h
//  Toolkit
//
//  Created by jack zhou on 12/26/13.
//  Copyright (c) 2013 JZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+(UIColor *)colorWithHex:(int)hex;
+ (UIColor *)colorWithHex:(int)hex alpha:(CGFloat)alpha;
+ (UIColor *) colorWithHexString: (NSString *) hexString;
@end
