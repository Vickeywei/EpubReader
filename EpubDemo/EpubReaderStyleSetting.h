//
//  EpubReaderStyleSetting.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface EpubReaderStyleSetting : NSObject
//字体大小
@property (nonatomic,strong) UIFont *font;

//行间距
@property (nonatomic,assign) CGFloat lineSpace;

//字体颜色
@property (nonatomic,strong) UIColor *textColor;

//缩进
@property (nonatomic,assign) CGFloat fristlineindent;

//段落间隔
@property (nonatomic,assign) CGFloat paragraphSpace;

//对齐方式
@property (nonatomic,assign)NSTextAlignment textAlignment;
@end
