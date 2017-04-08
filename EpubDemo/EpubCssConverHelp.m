//
//  EpubCssConverHelp.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "EpubCssConverHelp.h"
#import "UIColor+Hex.h"
#import "EpubReaderSetting.h"
@implementation EpubCssConverHelp

+ (NSDictionary *)convertWithAttribute:(NSDictionary *)attribute
{
    NSMutableDictionary *returnAttribute = [NSMutableDictionary dictionary];
    
    
    NSString *fontWidthStr = [attribute objectForKey:@"font-width"];
    if (fontWidthStr) {
        CGFloat fontWidth = [self converWithFontWidth:fontWidthStr];
        fontWidth += [EpubReaderSetting getFontWidth];
        [returnAttribute setObject:@(fontWidth) forKey:@"fontSize"];
        
    }
    //在这里替换成oc属性
    NSString *fontStr = [attribute objectForKey:@"font-size"];
    if (fontStr) {
        CGFloat fontSize = [self convertPointWithPixelStr:fontStr];
        fontSize += [EpubReaderSetting getFontSize];
        [returnAttribute setObject:@(fontSize) forKey:@"fontSize"];
    }
    NSString *colorStr = [attribute objectForKey:@"color"];
    if (colorStr) {
        [returnAttribute setObject:[UIColor colorWithHexString:colorStr] forKey:@"color"];
    }
    
    NSString *backgroundStr = [attribute objectForKey:@"background"];
    if (backgroundStr) {
        [returnAttribute setObject:[UIColor colorWithHexString:backgroundStr] forKey:@"background"];
    }
    
    NSString *textAlignStr = [attribute objectForKey:@"text-align"];
    if (textAlignStr) {
        NSTextAlignment textAlign = [self converWithTextAlignStr:textAlignStr];
        [returnAttribute setObject:@(textAlign) forKey:@"textAlign"];
    }
    NSString *marginTopStr = [attribute objectForKey:@"margin-top"];
    if (marginTopStr) {
        CGFloat marginTop = [self convertPointWithPixelStr:marginTopStr];
        [returnAttribute setObject:@(marginTop) forKey:@"marginTop"];
    }
    
    NSString *marginBottomStr = [attribute objectForKey:@"margin-bottom"];
    if (marginBottomStr) {
        CGFloat marginBottom = [self convertPointWithPixelStr:marginBottomStr];
        [returnAttribute setObject:@(marginBottom) forKey:@"marginBottom"];
    }
    NSString *paddingTopStr = [attribute objectForKey:@"padding-top"];
    if (paddingTopStr) {
        CGFloat paddingTop = [self convertPointWithPixelStr:paddingTopStr];
        [returnAttribute setObject:@(paddingTop) forKey:@"paddingTop"];
    }
    NSString *paddingBottomStr = [attribute objectForKey:@"padding-bottom"];
    if (paddingBottomStr) {
        CGFloat paddingBottom = [self convertPointWithPixelStr:paddingBottomStr];
        [returnAttribute setObject:@(paddingBottom) forKey:@"paddingBottom"];
    }
    
    NSString *lineSpaceStr = [attribute objectForKey:@"line-height"];
    if (lineSpaceStr) {
        CGFloat lineSpace = [self convertPointWithPixelStr:lineSpaceStr];
        lineSpace += [EpubReaderSetting getLineSpacing];
        [returnAttribute setObject:@(lineSpace) forKey:@"lineSpace"];
    }
    
    NSString *borderTopHeightStr = [attribute objectForKey:@"border-top-width"];
    if (borderTopHeightStr) {
        CGFloat borderTopHeight = [self convertPointWithPixelStr:borderTopHeightStr];
        [returnAttribute setObject:@(borderTopHeight) forKey:@"borderTopHeight"];
    }
    
    NSString *borderBottomHeightStr = [attribute objectForKey:@"border-bottom-width"];
    if (borderBottomHeightStr) {
        CGFloat borderBottomHeight = [self convertPointWithPixelStr:borderBottomHeightStr];
        [returnAttribute setObject:@(borderBottomHeight) forKey:@"borderBottomHeight"];
    }
    
    NSString *borderTopColor = [attribute objectForKey:@"border-top-color"];
    if (borderTopColor) {
        [returnAttribute setObject:[UIColor colorWithHexString:borderTopColor] forKey:@"borderTopColor"];
    }
    
    NSString *borderBottomColor = [attribute objectForKey:@"border-bottom-color"];
    if (borderBottomColor) {
        [returnAttribute setObject:[UIColor colorWithHexString:borderBottomColor] forKey:@"borderBottomColor"];
    }
    return [returnAttribute copy];
}

+ (CGFloat)convertPointWithPixelStr:(NSString *)pixelStr
{
    
    CGFloat value = 0;

    /*
     这里必须写一段注释，从 css 文件可以看出 font-Size这个，xx-large 和父容器的字体大小有关，在 css 中并没有找到父容器的大小到底是多少。所以这里给定 xx-large == 24float
     x-large = 22 float large = 20float  medium = 系统默认字体 17  small = 15
      x-small = 12 xx-small = 10
     
     */
    if ([pixelStr isEqualToString:@"xx-large"]) {
        value = 24;
        return value;
    }
    else if ([pixelStr isEqualToString:@"x-large"]){
        value = 22;
        return value;
    }
    else if ([pixelStr isEqualToString:@"large"]) {
        value = 20;
        return value;
    }
    else if ([pixelStr isEqualToString:@"medium"]){
        value = 17;
        return value;
    }
    else if ([pixelStr isEqualToString:@"small"]){
        value = 15;
        return value;
    }
    else if ([pixelStr isEqualToString:@"x-small"]){
        value = 12;
        return value;
    }
    else if ([pixelStr isEqualToString:@"xx-small"]){
        value = 10;
        return value;
    }
    NSRange range = [pixelStr rangeOfString:@"%"];
    if (range.location != NSNotFound) {
        CGFloat percent = [[pixelStr stringByReplacingOccurrencesOfString:@"%" withString:@""] floatValue] / 100;
        value = [UIScreen mainScreen].bounds.size.height * percent;
    }else{
        CGFloat pixel = [[pixelStr stringByReplacingOccurrencesOfString:@"px" withString:@""] floatValue];
        //        value = (pixel / 96) * 72;
        value = pixel;
    }
    return value;
}

+ (NSTextAlignment)converWithTextAlignStr:(NSString *)textAlignStr
{
    if ([textAlignStr isEqualToString:@"center"]) {
        return NSTextAlignmentCenter;
    }else if ([textAlignStr isEqualToString:@"left"]){
        return NSTextAlignmentLeft;
    }else if([textAlignStr isEqualToString:@"right"]){
        return NSTextAlignmentRight;
    }
    else {
        return NSTextAlignmentJustified;
    }
}

+ (CGFloat)converWithFontWidth:(NSString*)fontWidth {
    if ([fontWidth isEqualToString:@"bold"]) {
        return UIFontWeightBold;
    }
    else if ([fontWidth isEqualToString:@"nomall"]){
        return UIFontWeightMedium;
    }
    else {
       return UIFontWeightMedium;
    }
}

@end
