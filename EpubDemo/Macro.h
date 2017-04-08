//
//  Macro.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#ifndef Macro_h
#define Macro_h
#define WQ_INLINE static inline

#define IntroductionMark @"IntroductionMark"
#define ImageMark @"ImageMark"
#define keywordMark @"keywordMark"
#define summaryMark @"summaryMark"
#define quoteLineMark @"quoteLineMark"
#define audioMark @"audioMark"
#define videoMark @"videoMark"

#define ImageClick_ImageData @"ImageClick_ImageData"//被点击图片数据的key
#define ImageClick_ShowImageRect @"ImageClick_ShowImageRect"

#define RemarkClick_RemarkData @"RemarkClick_RemarkData" //被点击备注数据的key
#define RemarkClick_ShowRemarkRect @"RemarkClick_ShowRemarkRect"

#pragma mark - notification key

#define ImageClickActionNotification @"ImageClickActionNotification" //图片被点击
#define RemarkClickActionNotification @"RemarkClickActionNotification" //备注点击
#define ContentTouchActionNotification @"ContentTouchActionNotification"//页面被点击用于传递事件到控制器 显示设置菜单
//Format
#define F(string, args...)                  [NSString stringWithFormat:string, args]

#define RGB(r, g, b)                        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#endif /* Macro_h */
