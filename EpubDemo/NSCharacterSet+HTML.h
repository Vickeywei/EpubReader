//
//  NSCharacterSet+HTML.h
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/15/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//  解析html工具类

#import <Foundation/Foundation.h>

@interface NSCharacterSet (HTML)

+ (NSCharacterSet *)quoteCharacterSet;

+ (NSCharacterSet *)cssStyleAttributeNameCharacterSet;
@end
