//
//  ViewController.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/7.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "ViewController.h"
#import "EpubDestinationPath.h"
#import "EpubHTMLParser.h"
#import "Macro.h"
#import "EpubNcxModel.h"
#import "EpubContentViewController.h"
WQ_INLINE EpubHTMLParser *parser (){
    static EpubHTMLParser *parser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[EpubHTMLParser alloc] init];
    });
    return parser;
}

@interface ViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property(nonatomic,strong) UIPageViewController *pageViewController;
//当前阅读到章节
@property(nonatomic,assign)NSInteger chapterIndex;
//当前页码
@property (nonatomic,assign)NSInteger pageIndex;

@property(atomic,strong)NSMutableDictionary *cacheChapterDict;
@property(nonatomic,assign)NSInteger totalChapterCount;


@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageIndex = 0;
    _cacheChapterDict = @{}.mutableCopy;
    _chapterIndex = 0;
    BOOL result = extractFile();
    if (result) {
        NSLog(@"解压成功");
    }
    else {
        NSLog(@"解压失败");
    }
    NSLog(@"%@",creatDestinationPath());
    
    parser();
    self.totalChapterCount = parser().ncxInfo.chapterArray.count;
    self.pageViewController = [[UIPageViewController alloc] init];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    EpubChapterModel *chapterInfo = [parser() getChapterInfoWithIndex:self.chapterIndex];
    EpubContentViewController *contentVc = [[EpubContentViewController alloc]init];
    contentVc.chapterTitle = [chapterInfo.navLabel objectForKey:@"text"];
    contentVc.currentChapterIndex = self.chapterIndex;
    contentVc.currentPage = self.pageIndex;
    [parser() getReadContentWithIndex:self.chapterIndex success:^(NSArray *array) {
        [_cacheChapterDict setObject:array forKey:@(self.chapterIndex)];
        contentVc.totalPage = array.count;
        contentVc.data = [array objectAtIndex:self.pageIndex];
    }];
    [self.pageViewController setViewControllers:@[contentVc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - UIPageViewDataSource And UIPageViewDelegate
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    EpubContentViewController *currentContentVc = (EpubContentViewController *)viewController;
    EpubContentViewController *preContentVC = [[EpubContentViewController alloc]init];
    NSInteger currentPage = currentContentVc.currentPage;
    NSInteger currentChapterIndex = currentContentVc.currentChapterIndex;
    if (currentPage <= 0) {
        if (currentChapterIndex > 0) {
            currentChapterIndex -- ;
            self.chapterIndex = currentChapterIndex;
            EpubChapterModel *chapterInfo = [parser() getChapterInfoWithIndex:currentChapterIndex];
            NSArray *preChapterArray = [_cacheChapterDict objectForKey:@(currentChapterIndex)];
            if (preChapterArray) {
                preContentVC.chapterTitle = [chapterInfo.navLabel objectForKey:@"text"];
                preContentVC.currentChapterIndex = currentChapterIndex;
                preContentVC.currentPage = preChapterArray.count - 1;
                preContentVC.totalPage = preChapterArray.count;
                preContentVC.data = [preChapterArray lastObject];
            }else{
                pageViewController.view.userInteractionEnabled = NO;
                [preContentVC startLoading];
                
                __weak typeof(self) weakSelf = self;
                [parser() getReadContentWithIndex:currentChapterIndex success:^(NSArray *array) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (array) {
                        [_cacheChapterDict setObject:array forKey:@(currentChapterIndex)];
                        preContentVC.chapterTitle = [chapterInfo.navLabel objectForKey:@"text"];
                        preContentVC.currentChapterIndex = currentChapterIndex;
                        preContentVC.currentPage = array.count - 1;
                        preContentVC.totalPage = array.count;
                        preContentVC.data = [array lastObject];
                        pageViewController.view.userInteractionEnabled = YES;
                        [preContentVC endLoading];
                        [preContentVC loadData];
                        [preContentVC loadBackgroundColor];
                    }
                }];
            }
            return preContentVC;
        }else{
            NSLog(@"已经是第一页了");
            return nil;
        }
    }else{
        //没有跨章
        NSArray *currentChapterArray = [_cacheChapterDict objectForKey:@(currentChapterIndex)];
        preContentVC.chapterTitle = currentContentVc.chapterTitle;
        preContentVC.currentChapterIndex = currentChapterIndex;
        preContentVC.currentPage = currentPage - 1;
        preContentVC.totalPage = currentChapterArray.count;
        preContentVC.data = [currentChapterArray objectAtIndex:currentPage - 1];
        return preContentVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    EpubContentViewController *currentContentVc = (EpubContentViewController *)viewController;
    EpubContentViewController *nextContentVc = [[EpubContentViewController alloc]init];

    NSInteger currentPage = currentContentVc.currentPage;
    NSInteger currentChapterIndex = currentContentVc.currentChapterIndex;
    NSArray *currentChapterArray = [_cacheChapterDict objectForKey:@(currentChapterIndex)];
    
    if (currentPage >= currentChapterArray.count - 1){
        if (currentChapterIndex < self.totalChapterCount - 1){
            currentChapterIndex ++;
            //每次跨章保存阅读记录
        
            self.chapterIndex = currentChapterIndex;
           EpubChapterModel *chapterInfo = [parser() getChapterInfoWithIndex:currentChapterIndex];
            NSArray *nextChapterArray = [_cacheChapterDict objectForKey:@(currentChapterIndex)];
            if (nextChapterArray) {
                nextContentVc.chapterTitle = [chapterInfo.navLabel objectForKey:@"text"];
                nextContentVc.currentChapterIndex = currentChapterIndex;
                nextContentVc.currentPage = 0;
                nextContentVc.totalPage = nextChapterArray.count;
                nextContentVc.data = [nextChapterArray firstObject];
            }else{
                pageViewController.view.userInteractionEnabled = NO;
                [nextContentVc startLoading];
                __weak typeof(self) weakSelf = self;
                [parser() getReadContentWithIndex:currentChapterIndex success:^(NSArray *array) {
                     __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (array) {
                        [_cacheChapterDict setObject:array forKey:@(currentChapterIndex)];
                        nextContentVc.chapterTitle = [chapterInfo.navLabel objectForKey:@"text"];
                        nextContentVc.currentChapterIndex = currentChapterIndex;
                        nextContentVc.currentPage = 0;
                        nextContentVc.totalPage = array.count;
                        nextContentVc.data = [array firstObject];
                        pageViewController.view.userInteractionEnabled = YES;
                        [nextContentVc endLoading];
                        [nextContentVc loadData];
                        [nextContentVc loadBackgroundColor];
                    }
                }];
            }
            return nextContentVc;
        }else{
            NSLog(@"没有更多内容了");
            return nil;
        }
    }else{
        nextContentVc.chapterTitle = currentContentVc.chapterTitle;
        nextContentVc.currentChapterIndex = currentChapterIndex;
        nextContentVc.currentPage = currentPage + 1;
        nextContentVc.totalPage = currentChapterArray.count;
        nextContentVc.data = [currentChapterArray objectAtIndex:currentPage + 1];
        return nextContentVc;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
