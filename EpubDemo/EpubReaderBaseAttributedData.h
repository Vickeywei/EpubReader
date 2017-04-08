//
//  EpubReaderBaseAttributedData.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface EpubReaderBaseAttributedData : NSObject
@property(nonatomic,copy) NSString *tagName;
@property(nonatomic,copy) NSString *className;
@property(nonatomic,assign) NSRange range;
@end

@interface EpubReaderKeyWordData : EpubReaderBaseAttributedData
@property(nonatomic,strong) UIColor *backgroundColor;
@property(nonatomic,assign) CGRect rect;
@end


@interface EpubReaderPrefaceData : EpubReaderBaseAttributedData
@property(nonatomic,strong) UIColor *lineColor;
@property(nonatomic,assign) CGRect leftLineRect;
@property(nonatomic,assign) CGRect bottomLineRect;

@end

@interface EpubReaderCommentData : EpubReaderBaseAttributedData
@property(nonatomic,strong) UIColor *backgroundColor;
@property(nonatomic,assign) CGRect rect;
@property(nonatomic,copy) NSString *title;
@end

@interface EpubReaderImageData : EpubReaderBaseAttributedData
@property (nonatomic,strong)NSString *imageSrc;
@property (nonatomic,assign)CGRect imagePosition;
@end

@interface EpubReaderLineData : EpubReaderBaseAttributedData
@property(nonatomic,strong) UIColor *lineColor;
@property(nonatomic,assign) CGFloat left;
@property(nonatomic,assign) CGFloat top;
@property(nonatomic,assign) CGFloat width;
@property(nonatomic,assign) CGFloat height;
@property(nonatomic,assign) NSInteger type; //1 为top  2为bottom
@end
