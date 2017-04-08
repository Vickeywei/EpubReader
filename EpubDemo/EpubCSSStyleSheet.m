//
//  EpubCSSStyleSheet.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "EpubCSSStyleSheet.h"
#import "NSString+CSS.h"
#import "NSScanner+HTML.h"
@interface EpubCSSStyleSheet ()
@property (nonatomic,strong)NSMutableDictionary *styles;
@property (nonatomic,strong)NSMutableArray *selectors;

@end


@implementation EpubCSSStyleSheet
- (id)initWithStyleBlock:(NSString *)css
{
    self = [super init];
    if (self)
    {
        _styles	= [NSMutableDictionary dictionary];
        _selectors = [NSMutableArray array];
        [self parseStyleBlock:css];
    }
    return self;
}

- (void)addStyleRule:(NSString *)rule withSelector:(NSString*)selectors
{
    NSArray *split = [selectors componentsSeparatedByString:@","];
    for (NSString *selector in split)
    {
        NSString *cleanSelector = [selector stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableDictionary *ruleDictionary = [[rule dictionaryOfCSSStyles] mutableCopy];
        for (NSString *oneKey in [ruleDictionary allKeys])
        {
            id value = [ruleDictionary objectForKey:oneKey];
            if ([value isKindOfClass:[NSString class]])
            {
                NSRange rangeOfImportant = [value rangeOfString:@"!important" options:NSCaseInsensitiveSearch];
                if (rangeOfImportant.location != NSNotFound)
                {
                    value = [value stringByReplacingCharactersInRange:rangeOfImportant withString:@""];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [ruleDictionary setObject:value forKey:oneKey];
                }
            } else if ([value isKindOfClass:[NSArray class]])
            {
                NSMutableArray *newVal;
                for (NSUInteger i = 0; i < [(NSArray*)value count]; ++i)
                {
                    NSString *s = [value objectAtIndex:i];
                    NSRange rangeOfImportant = [s rangeOfString:@"!important" options:NSCaseInsensitiveSearch];
                    if (rangeOfImportant.location != NSNotFound)
                    {
                        s = [s stringByReplacingCharactersInRange:rangeOfImportant withString:@""];
                        s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if (!newVal)
                        {
                            if ([value isKindOfClass:[NSMutableArray class]])
                            {
                                newVal = value;
                            } else
                            {
                                newVal = [value mutableCopy];
                            }
                        }
                        [newVal replaceObjectAtIndex:i withObject:s];
                    }
                }
                if (newVal)
                {
                    [ruleDictionary setObject:newVal forKey:oneKey];
                }
            }
        }
        NSRange colonRange = [cleanSelector rangeOfString:@":"];
        NSString *pseudoSelector = nil;
        if (colonRange.length==1)
        {
            pseudoSelector = [cleanSelector substringFromIndex:colonRange.location+1];
            cleanSelector = [cleanSelector substringToIndex:colonRange.location];
            for (NSString *oneRuleKey in [ruleDictionary allKeys])
            {
                id value = [ruleDictionary objectForKey:oneRuleKey];
                NSString *prefixedKey = [NSString stringWithFormat:@"%@:%@", pseudoSelector, oneRuleKey];
                [ruleDictionary setObject:value forKey:prefixedKey];
                [ruleDictionary removeObjectForKey:oneRuleKey];
            }
        }
        NSDictionary *existingRulesForSelector = [_styles objectForKey:cleanSelector];
        if (existingRulesForSelector)
        {
            NSMutableDictionary *tmpDict = [existingRulesForSelector mutableCopy];
            [tmpDict addEntriesFromDictionary:ruleDictionary];
            [self addStyles:tmpDict withSelector:cleanSelector];
        }
        else
        {
            [self addStyles:ruleDictionary withSelector:cleanSelector];
        }
    }
}

- (void)parseStyleBlock:(NSString*)css
{
    NSUInteger braceLevel = 0, braceMarker = 0;
    NSString* selector;
    NSUInteger length = [css length];
    for (NSUInteger i = 0; i < length; i++)
    {
        unichar c = [css characterAtIndex:i];
        if (c == '/')
        {
            i++;
            if (i < length)
            {
                c = [css characterAtIndex:i];
                if (c == '*')
                {
                    for (; i < length; i++)
                    {
                        if ([css characterAtIndex:i] == '/')
                        {
                            break;
                        }
                    }
                    if (i < length)
                    {
                        braceMarker = i+1;
                        continue;
                    }
                    else
                    {
                        return;
                    }
                }
                else
                {
                    i--;
                }
            }
        }
        if (c == '{')
        {
            if (braceLevel == 0)
            {
                selector = [css substringWithRange:NSMakeRange(braceMarker, i-braceMarker)];
                NSArray *selectorParts = [selector componentsSeparatedByString:@" "];
                NSMutableArray *cleanSelectorParts = [NSMutableArray array];
                for (NSString *partialSelector in selectorParts)
                {
                    if (partialSelector.length)
                    {
                        [cleanSelectorParts addObject:partialSelector];
                    }
                }
                selector = [cleanSelectorParts componentsJoinedByString:@" "];
                braceMarker = i + 1;
            }
            braceLevel += 1;
        }
        else if (c == '}')
        {
            if (braceLevel == 1)
            {
                NSString *rule = [css substringWithRange:NSMakeRange(braceMarker, i-braceMarker)];
                [self addStyleRule:rule withSelector: selector];
                braceMarker = i + 1;
            }
            braceLevel = MAX(braceLevel-1, 0ul);
        }
    }
}

- (void)addStyles:(NSDictionary *)styles withSelector:(NSString *)selector {
    [_styles setObject:styles forKey:selector];
    if (![_selectors containsObject:selector]) {
        [_selectors addObject:selector];
    }
}

- (NSDictionary *)styles
{
    return _styles;
}

-(NSArray *)selectors
{
    return _selectors;
}
@end
