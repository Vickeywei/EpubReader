//
//  EpubReaderSetting.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "EpubReaderSetting.h"

@implementation EpubReaderSetting

/**
 *  设置屏幕亮度
 */
+ (void)setScrrenLightLevel:(CGFloat)brightness
{
    [[NSUserDefaults standardUserDefaults] setFloat:brightness forKey:@"reader_brightness"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  获取屏幕亮度值
 */
+ (CGFloat)getScreenLightLevel
{
    CGFloat brightness = [[NSUserDefaults standardUserDefaults] floatForKey:@"reader_brightness"];
    return brightness;
}

/**
 *  设置行间距
 */
+ (void)setLineSpacing:(NSInteger)lineSpacing
{
    [[NSUserDefaults standardUserDefaults] setInteger:lineSpacing forKey:@"reader_LineSpacing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  获取行间距
 */
+ (NSInteger)getLineSpacing
{
    NSInteger lineSpacing = [[NSUserDefaults standardUserDefaults] integerForKey:@"reader_LineSpacing"];
    return lineSpacing;
}

/**
 *  设置字体大小
 */
+ (void)setFontSize:(NSInteger)fontSize
{
    [[NSUserDefaults standardUserDefaults] setInteger:fontSize forKey:@"reader_fontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  获取字体
 */
+ (NSInteger)getFontSize
{
    NSInteger fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"reader_fontSize"];
    return fontSize;
}

/**
 *  设置字体粗细
 */
+ (void)setFontWidth:(CGFloat)fontWidth {
    [[NSUserDefaults standardUserDefaults] setInteger:fontWidth forKey:@"reader_fontWidth"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  获取字体
 */
+ (NSInteger)getFontWidth {
    NSInteger fontWidth = [[NSUserDefaults standardUserDefaults] integerForKey:@"reader_fontWidth"];
    return fontWidth;
}

/**
 *  设置阅读背景
 */
+ (void)setReadBackgroundIndex:(NSInteger)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"reader_backgroundIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  获取阅读背景
 */
+ (NSInteger)getReadBackGroundIndex
{
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"reader_backgroundIndex"];
    return index;
}

/**
 *  设置日夜间模式
 *
 *  @param dayNightMode YES->夜间  NO->日间
 */
+ (void)setDayNightMode:(BOOL)dayNightMode
{
    [[NSUserDefaults standardUserDefaults] setBool:dayNightMode forKey:@"reader_dayNightMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  获取日夜间模式
 *
 *  @return YES->夜间  NO->日间
 */
+ (BOOL)getDayNightMode
{
    BOOL dayNightMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"reader_dayNightMode"];
    return dayNightMode;
}

/**
 *  设置常亮模式
 */
+ (void)setAlwaysLight:(BOOL)mode
{
    [[NSUserDefaults standardUserDefaults] setBool:mode forKey:@"reader_alwaysLight"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  获取是否是常亮模式
 */
+ (BOOL)getAlwaysLight
{
    BOOL alwaysLight = [[NSUserDefaults standardUserDefaults] boolForKey:@"reader_alwaysLight"];
    return alwaysLight;
}
@end
