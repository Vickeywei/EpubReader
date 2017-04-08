//
//  EpubContentViewController.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EpubReaderData;
@interface EpubContentViewController : UIViewController
@property(nonatomic,strong)EpubReaderData *data;
@property(nonatomic,assign)NSInteger currentChapterIndex;
@property(nonatomic,assign)NSInteger currentPage;
@property(nonatomic,assign)NSInteger totalPage;
@property(nonatomic,copy) NSString *chapterTitle;
@property(nonatomic,strong)NSArray *readBackgrounds;

- (void)loadData;
- (void)loadBackgroundColor;
- (void)startLoading;
- (void)endLoading;
@end
