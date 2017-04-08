//
//  EpubNcxFileParser.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"
#import <XMLDictionary.h>
WQ_INLINE NSDictionary * parserNcxFile(NSString *ncxFilePath){
    NSDictionary *dict = [NSDictionary dictionaryWithXMLFile:ncxFilePath];
    return dict;
}
