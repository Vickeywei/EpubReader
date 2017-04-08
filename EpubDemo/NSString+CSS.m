//
//  NSString+CSS.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 31.01.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "NSString+CSS.h"
#import "NSScanner+HTML.h"
@implementation NSString (CSS)

- (NSDictionary *)dictionaryOfCSSStyles
{
	NSScanner *scanner = [NSScanner scannerWithString:self];
	
	NSString *name = nil;
	NSString *value = nil;
	
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
	
	@autoreleasepool
	{
		while ([scanner scanCSSAttribute:&name value:&value])
		{
			[tmpDict setObject:value forKey:name];
		}
	}
	return tmpDict;
}

@end
