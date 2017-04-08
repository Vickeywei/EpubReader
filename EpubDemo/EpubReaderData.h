//
//  EpubReaderData.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreText;
@interface EpubReaderBaseData : NSObject
@property (nonatomic,assign) NSRange pageRange;
@end

@interface EpubReaderData :EpubReaderBaseData
@property (nonatomic,assign) CTFrameRef ctFrame;
@property (nonatomic,strong) NSArray *prefaceArray;
@property (nonatomic,strong) NSArray *keywordArray;
@property (nonatomic,strong) NSArray *commentArray;
@property (nonatomic,strong) NSArray *lineArray;
@property (nonatomic,strong) NSArray *imageArray;

-(void)computePosition;
@end
