//
//  EpubHTMLParser.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EpubNcxModel,EpubChapterModel;

typedef void(^success)(NSArray *array);
@interface EpubHTMLParser : NSObject
@property (nonatomic, strong) EpubNcxModel *ncxInfo;
-(EpubChapterModel *)getChapterInfoWithIndex:(NSInteger)index;
-(void)getReadContentWithIndex:(NSInteger)index success:(success)success;


@end
