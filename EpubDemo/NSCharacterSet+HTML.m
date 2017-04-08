//
//  NSCharacterSet+HTML.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/15/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "NSCharacterSet+HTML.h"

static NSCharacterSet *_tagNameCharacterSet = nil;
static NSCharacterSet *_ignorableWhitespaceCharacterSet = nil;
static NSCharacterSet *_tagAttributeNameCharacterSet = nil;
static NSCharacterSet *_quoteCharacterSet = nil;
static NSCharacterSet *_nonQuotedAttributeEndCharacterSet = nil;
static NSCharacterSet *_cssStyleAttributeNameCharacterSet = nil;
static NSCharacterSet *_cssLengthValueCharacterSet = nil;
static NSCharacterSet *_cssLengthUnitCharacterSet = nil;



@implementation NSCharacterSet (HTML)

+ (NSCharacterSet *)quoteCharacterSet
{
	static dispatch_once_t predicate;

	dispatch_once(&predicate, ^{
		_quoteCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"'\""];
	});
	
	return _quoteCharacterSet;
}

+ (NSCharacterSet *)cssStyleAttributeNameCharacterSet
{
	static dispatch_once_t predicate;

	dispatch_once(&predicate, ^{
		_cssStyleAttributeNameCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"];
	});	
	return _cssStyleAttributeNameCharacterSet;
}


+ (NSCharacterSet *)cssLengthValueCharacterSet
{
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		_cssLengthValueCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
	});
	return _cssLengthValueCharacterSet;
}

+ (NSCharacterSet *)cssLengthUnitCharacterSet
{
	static dispatch_once_t predicate;
	
	dispatch_once(&predicate, ^{
		_cssLengthUnitCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"pxtem"];
	});
	return _cssLengthUnitCharacterSet;
}

@end
