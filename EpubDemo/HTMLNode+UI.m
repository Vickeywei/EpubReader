//
//  HTMLNode+UI.m
//  CoreTextReader
//
//  Created by 戴志朋 on 15/7/3.
//  Copyright (c) 2015年 liufeng. All rights reserved.
//

#import "HTMLNode+UI.h"

@implementation HTMLNode (UI)

-(NSString*)content
{
    if (_node->content) {
        return [NSString stringWithCString:(void*)_node->content encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end
