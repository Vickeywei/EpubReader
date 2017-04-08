//
//  EpubNcxModel.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EpubChapterModel;
@interface EpubNcxModel : NSObject
@property (nonatomic, strong) NSDictionary *navMap;
@property (nonatomic, strong) NSDictionary *docTitle;
@property (nonatomic, strong) NSDictionary *docAuthor;
@property (nonatomic, strong) NSArray <EpubChapterModel *>*chapterArray;

@end

@interface EpubChapterModel :NSObject
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSDictionary *navLabel;
@property (nonatomic, strong) NSString *_playOrder;
@property (nonatomic, strong) NSDictionary *content;


@end
