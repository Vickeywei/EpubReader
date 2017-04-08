//
//  EpubNcxModel.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "EpubNcxModel.h"
#import <NSObject+YYModel.h>
@implementation EpubNcxModel
- (NSArray<EpubChapterModel *> *)chapterArray {
    NSMutableArray *chapterArray = @[].mutableCopy;
    NSArray *navPointArray = [_navMap objectForKey:@"navPoint"];
    for (NSDictionary *dic in navPointArray) {
        if ([dic[@"navPoint"] count] > 0) {
            for (NSDictionary *navPoint in dic[@"navPoint"]) {
                EpubChapterModel *model = [EpubChapterModel yy_modelWithDictionary:navPoint];
                [chapterArray addObject:model];
            }
        }
        EpubChapterModel *model = [EpubChapterModel yy_modelWithDictionary:dic];
        [chapterArray addObject:model];
    }
    return chapterArray;
}
@end

@implementation EpubChapterModel



@end
