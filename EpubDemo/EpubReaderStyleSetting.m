//
//  EpubReaderStyleSetting.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "EpubReaderStyleSetting.h"
#import "EpubReaderSetting.h"
#import "Macro.h"
@implementation EpubReaderStyleSetting
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.font = [UIFont systemFontOfSize:18 + [EpubReaderSetting getFontSize]];
        self.lineSpace = 8 + [EpubReaderSetting getLineSpacing];
        self.fristlineindent = self.font.pointSize * 1.5;
        self.paragraphSpace = 10.0f;
        if ([EpubReaderSetting getDayNightMode]) {
            self.textColor = RGB(144, 144, 144);
        }else{
            self.textColor = RGB(50, 50, 50);
        }
        self.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

-(void)setFont:(UIFont *)font
{
    _font = font;
    self.fristlineindent = font.pointSize * 1.5;
}
@end
