//
//  EpubCSSStyleSheet.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EpubCSSStyleSheet : NSObject
- (id)initWithStyleBlock:(NSString *)css;

- (void)parseStyleBlock:(NSString *)css;

- (NSDictionary *)styles;

- (NSArray *)selectors;
@end
