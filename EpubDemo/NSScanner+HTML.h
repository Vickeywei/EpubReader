//
//  NSScanner+HTML.h
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/12/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//  解析html工具类

#import <Foundation/Foundation.h>

@interface NSScanner (HTML)

- (BOOL)scanCSSAttribute:(NSString * __autoreleasing*)name value:(id __autoreleasing*)value;

@end

