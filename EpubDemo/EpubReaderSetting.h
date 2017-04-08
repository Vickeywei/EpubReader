//
//  EpubReaderSetting.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface EpubReaderSetting : NSObject
/**
 *  设置屏幕亮度
 */
+ (void)setScrrenLightLevel:(CGFloat)brightness;

/**
 *  获取屏幕亮度值
 */
+ (CGFloat)getScreenLightLevel;

/**
 *  设置行间距
 */
+ (void)setLineSpacing:(NSInteger)lineSpacing;

/**
 *  获取行间距
 */
+ (NSInteger)getLineSpacing;

/**
 *  设置字体大小
 */
+ (void)setFontSize:(NSInteger)fontSize;

/**
 *  获取字体
 */
+ (NSInteger)getFontSize;

/**
 *  设置阅读背景
 */
+ (void)setReadBackgroundIndex:(NSInteger)index;

/**
 *  获取阅读背景
 */
+ (NSInteger)getReadBackGroundIndex;

/**
 *  设置日夜间模式
 *
 *  @param dayNightMode YES->夜间  NO->日间
 */
+ (void)setDayNightMode:(BOOL)dayNightMode;

/**
 *  获取日夜间模式
 *
 *  @return YES->夜间  NO->日间
 */
+ (BOOL)getDayNightMode;

/**
 *  设置常亮模式
 */
+ (void)setAlwaysLight:(BOOL)mode;

/**
 *  获取是否是常亮模式
 */
+ (BOOL)getAlwaysLight;


/**
 *  设置字体粗细
 */
+ (void)setFontWidth:(CGFloat)fontWidth;

/**
 *  获取字体
 */
+ (NSInteger)getFontWidth;
@end
