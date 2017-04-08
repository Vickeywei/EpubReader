//
//  EpubContentViewController.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "EpubContentViewController.h"
#import "Macro.h"
#import "EpubReaderSetting.h"
#import "UIView+Layout.h"
#import "EpubCoreTextView.h"
@interface EpubContentViewController ()
@property(nonatomic,strong)UILabel *chapterLabel;
@property(nonatomic,strong)EpubCoreTextView *coreTextView;
@property(nonatomic,strong)UILabel *pageLabel;
@property(nonatomic,strong)UIActivityIndicatorView *promptView;
@end

@implementation EpubContentViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
    [self loadBackgroundColor];
}

- (void)setupView
{
    
    self.chapterLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.width - 30, 40)];
    self.chapterLabel.font = [UIFont systemFontOfSize:14];
    self.chapterLabel.textColor = RGB(130, 130, 130);
    [self.view addSubview:self.chapterLabel];
    
    self.coreTextView = [[EpubCoreTextView alloc]initWithFrame:CGRectMake(0, self.chapterLabel.bottom, self.view.width, self.view.height - self.chapterLabel.bottom - 30)];
    [self.view addSubview:self.coreTextView];
    
    self.pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, self.coreTextView.bottom + 5, self.view.width - 30, 20)];
    self.pageLabel.font = [UIFont systemFontOfSize:14];
    self.pageLabel.textColor = RGB(130, 130, 130);
    self.pageLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.pageLabel];
}

- (void)loadData
{
    if (self.data) {
        self.chapterLabel.text = self.chapterTitle;
        self.coreTextView.data = self.data;
        self.pageLabel.text = F(@"%zd/%zd", self.currentPage + 1,self.totalPage);
    }
}

- (void)loadBackgroundColor
{
    if ([EpubReaderSetting getDayNightMode]) {
        self.view.backgroundColor = RGB(0, 0, 0);
    }else{
        self.view.backgroundColor = [self.readBackgrounds objectAtIndex:[EpubReaderSetting getReadBackGroundIndex]];
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

-(void)startLoading
{
    self.promptView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[EpubReaderSetting getDayNightMode] ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray];
    self.promptView.center = self.view.center;
    [self.promptView startAnimating];
    [self.view addSubview:self.promptView];
}

-(void)endLoading
{
    [self.promptView stopAnimating];
}

@end
