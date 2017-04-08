//
//  EpubHTMLParser.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "EpubHTMLParser.h"
#import "EpubNcxFileParser.h"
#import "EpubDestinationPath.h"
#import <NSObject+YYModel.h>
#import "EpubNcxModel.h"
#import "HTMLNode+UI.h"
#import "HTMLNode.h"
#import "HTMLParser.h"
#import <CoreText/CoreText.h>
#import "EpubReaderBaseAttributedData.h"
#import "EpubCSSStyleSheet.h"
#import "EpubCssConverHelp.h"
#import "EpubReaderStyleSetting.h"
#import "EpubReaderData.h"
@interface EpubHTMLParser ()
//缓存所有解析后的 html
@property(nonatomic,strong) NSMutableDictionary *cacheDictionary;
@property(nonatomic,strong) NSMutableDictionary *parserMarkCacheDict;
@property(nonatomic,strong) NSMutableDictionary *dataCacheDictonary;
@end

@implementation EpubHTMLParser

- (instancetype)init {
    self = [super init];
    if (self) {
        _cacheDictionary = @{}.mutableCopy;
        _parserMarkCacheDict = @{}.mutableCopy;
        _dataCacheDictonary = @{}.mutableCopy;
        [self setUpData];
    }
    return self;
}

- (void)setUpData{
    NSString *ncxFilePath = [[creatDestinationPath() stringByAppendingPathComponent:@"OPS"] stringByAppendingPathComponent:@"fb.ncx"];
    NSDictionary *dic = parserNcxFile(ncxFilePath);
    self.ncxInfo = [EpubNcxModel yy_modelWithDictionary:dic];
    
    for (int i = 0 ; i < self.ncxInfo.chapterArray.count;  i ++) {
        EpubChapterModel *chapterModel = self.ncxInfo.chapterArray[i];
        NSString *htmlFile = [chapterModel.content objectForKey:@"_src"];
        NSString *htmlFilePath = [[creatDestinationPath() stringByAppendingPathComponent:@"OPS"] stringByAppendingPathComponent:htmlFile];
        NSString *htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
        [self parserEpubBookWithHtmlString:htmlString index:i];
    }
}

-(void)getReadContentWithIndex:(NSInteger)index success:(success)success {
    NSArray *array = [_dataCacheDictonary objectForKey:@(index)];
    if (array) {
        success(array);
    }
    else{
        if (self.ncxInfo.chapterArray.count > 0) {
            EpubChapterModel *chapterModel = self.ncxInfo.chapterArray[index];
            NSString *htmlFile = [chapterModel.content objectForKey:@"_src"];
            
            NSString *htmlFilePath = [[creatDestinationPath() stringByAppendingPathComponent:@"OPS"] stringByAppendingPathComponent:htmlFile];
            NSString *htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
            NSArray *array = [self parserEpubBookWithHtmlString:htmlString index:index];
            if (success) {
                success(array);
            }
        }
        else {
            [self setUpData];
            NSArray *array = [_dataCacheDictonary objectForKey:@(index)];
            if (array) {
                success(array);
            }
        }
    

    }
}

-(EpubChapterModel *)getChapterInfoWithIndex:(NSInteger)index
{
    if (index <= self.ncxInfo.chapterArray.count - 1) {
        EpubChapterModel *chapterInfo = [self.ncxInfo.chapterArray objectAtIndex:index];
        return chapterInfo;
    }
    return nil;
}

- (NSArray *)parserEpubBookWithHtmlString:(NSString*)htmlString index:(NSInteger)index {
    NSMutableAttributedString *attributedString = [self.cacheDictionary objectForKey:F(@"%ld",(long)index)];
    //获取标记属性数组
    NSMutableArray *markArray = [self.parserMarkCacheDict objectForKey:F(@"%ld",(long)index)];
    //之前没有加载过,解析html
    if (attributedString == nil && markArray == nil) {
        NSError *error;
        HTMLParser *parser = [[HTMLParser alloc]initWithString:htmlString error:&error];
        if (error) {
            return nil;
        }
        HTMLNode *bodyNode = [parser body];
        markArray = [NSMutableArray array];
        attributedString = [self parserEpubBookWithHTMLNode:bodyNode markArray:markArray];
        
        [self.cacheDictionary setObject:attributedString forKey:F(@"%zd",index)];
        [self.parserMarkCacheDict setObject:markArray forKey:F(@"%zd",index)];
    }
    NSMutableArray *prefaceArray = [NSMutableArray array];
    NSMutableArray *keywordArray = [NSMutableArray array];
    NSMutableArray *commentArray = [NSMutableArray array];
    NSMutableArray *lineArray = [NSMutableArray array];
    NSMutableArray *imageArray = [NSMutableArray array];
    
    NSString *cssPath = [[[creatDestinationPath() stringByAppendingPathComponent:@"OPS"] stringByAppendingPathComponent:@"css"]stringByAppendingPathComponent:@"main.css"];
    NSString *cssContent = [NSString stringWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:NULL];
    EpubCSSStyleSheet *cssStylesheet = [[EpubCSSStyleSheet alloc] initWithStyleBlock:cssContent];
    
    [self addCssStyleWithAttributedString:attributedString cssStylesheet:cssStylesheet markArray:markArray prefaceArray:prefaceArray keywordArray:keywordArray commentArray:commentArray lineArray:lineArray imageArray:imageArray];
    
    NSArray *array = [self parserEpubBookWithAttributedString:attributedString prefaceArray:prefaceArray keywordArray:keywordArray commentArray:commentArray lineArray:lineArray imageArray:imageArray];
    [_dataCacheDictonary setObject:array forKey:@(index)];
    
    return array;
}

- (NSMutableDictionary *)attributesWithData:(EpubReaderStyleSetting *)data {
    //段落
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping; //换行模式
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    
    long kernNumber = 0;
    CFNumberRef kernNum = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &kernNumber);
    
    //行间距
    CGFloat lineSpacing = data.lineSpace;
    CTParagraphStyleSetting LineSpacing;
    LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    LineSpacing.value = &lineSpacing;
    LineSpacing.valueSize = sizeof(CGFloat);
    
    //对齐方式
    CTParagraphStyleSetting alignmentStyle;
    CTTextAlignment alignment;
    switch (data.textAlignment) {
            case NSTextAlignmentCenter:
            alignment = kCTTextAlignmentCenter;
            break;
            case NSTextAlignmentRight:
            alignment = kCTTextAlignmentRight;
            break;
        default:
            alignment = kCTJustifiedTextAlignment;
            break;
    }
    alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
    alignmentStyle.value = &alignment;
    alignmentStyle.valueSize = sizeof(alignment);
    
    //段落与段落之间间隔
    CGFloat paragraphspace = data.paragraphSpace;
    CTParagraphStyleSetting paragraph;
    paragraph.spec = kCTParagraphStyleSpecifierParagraphSpacing;
    paragraph.value = &paragraphspace;
    paragraph.valueSize = sizeof(CGFloat);
    
    //首行缩进
    CGFloat fristlineindent = data.fristlineindent;
    CTParagraphStyleSetting fristline;
    fristline.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
    fristline.value = &fristlineindent;
    fristline.valueSize = sizeof(CGFloat);
    
    CTParagraphStyleSetting settings[] = {lineBreakMode,LineSpacing,alignmentStyle,paragraph,fristline};
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(settings, 5);
    
    UIColor * textColor = data.textColor;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)data.font.fontName, data.font.pointSize, NULL);
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    dict[(id)kCTKernAttributeName] = (__bridge id)(kernNum);
    
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    
    return dict;
}

//解析html
- (NSMutableAttributedString *)parserEpubBookWithHTMLNode:(HTMLNode *)htmlNode markArray:(NSMutableArray *)markArray
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
    for (HTMLNode *childNode in htmlNode.children) {
        //引言
        if ([childNode.tagName isEqualToString:@"div"]) {
            for (HTMLNode *childernNode in childNode.children) {
                
                
                if ([childernNode.tagName isEqualToString:@"div"]) {
                    for (HTMLNode *node in childernNode.children) {
                        if ([node.tagName isEqualToString:@"img"]) {
                            NSString *string = [node getAttributeNamed:@"src"];
                            NSString *imageSrc = [[creatDestinationPath() stringByAppendingPathComponent:@"OPS"]stringByAppendingPathComponent:string];
                            NSAttributedString *appendString = [self parseImageDataWithSrc:imageSrc];
                            
                            EpubReaderImageData *data = [[EpubReaderImageData alloc]init];
                            data.tagName = node.tagName;
                            data.className = node.className;
                            data.range = NSMakeRange(attributedString.length, appendString.length);
                            data.imageSrc = imageSrc;
                            [markArray addObject:data];
                            [attributedString appendAttributedString:appendString];
                        }
                    }
                   
                }
                else if ([childernNode.tagName isEqualToString:@"h1"]){
                    for (HTMLNode *node in childernNode.children) {
                        if ([node.tagName isEqualToString:@"text"]) {
                            NSString *content = node.content;
                            if (content) {
                                NSMutableAttributedString *appendString = [[NSMutableAttributedString alloc]initWithString:content];
                                
                                EpubReaderBaseAttributedData *data = [[EpubReaderBaseAttributedData alloc]init];
                                data.tagName = childernNode.tagName;
                                data.className = childernNode.className;
                                data.range = NSMakeRange(attributedString.length, appendString.length);
                                [markArray addObject:data];
                                
                                [attributedString appendAttributedString:appendString];
                            }
                            [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                        }
                    }
                }
                else if ([childernNode.tagName isEqualToString:@"h2"]){
                    for (HTMLNode *node in childernNode.children) {
                        if ([node.tagName isEqualToString:@"text"]) {
                            NSString *content = node.content;
                            if (content) {
                                NSMutableAttributedString *appendString = [[NSMutableAttributedString alloc]initWithString:content];
                                
                                EpubReaderBaseAttributedData *data = [[EpubReaderBaseAttributedData alloc]init];
                                data.tagName = childernNode.tagName;
                                data.className = childernNode.className;
                                data.range = NSMakeRange(attributedString.length, appendString.length);
                                [markArray addObject:data];
                                
                                [attributedString appendAttributedString:appendString];
                            }
                             [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                        }
                        
                        
                    }
                }
                else if ([childernNode.tagName isEqualToString:@"h3"]){
                    for (HTMLNode *node in childernNode.children) {
                        if ([node.tagName isEqualToString:@"text"]) {
                            NSString *content = node.content;
                            if (content) {
                                NSMutableAttributedString *appendString = [[NSMutableAttributedString alloc]initWithString:content];
                                
                                EpubReaderBaseAttributedData *data = [[EpubReaderBaseAttributedData alloc]init];
                                data.tagName = childernNode.tagName;
                                data.className = childernNode.className;
                                data.range = NSMakeRange(attributedString.length, appendString.length);
                                [markArray addObject:data];
                                
                                [attributedString appendAttributedString:appendString];
                            }
                            [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                        }
                        
                    }
                }
                else if ([childernNode.tagName isEqualToString:@"h5"]){
                    for (HTMLNode *node in childernNode.children) {
                        if ([node.tagName isEqualToString:@"text"]) {
                            NSString *content = node.content;
                            if (content) {
                                NSMutableAttributedString *appendString = [[NSMutableAttributedString alloc]initWithString:content];
                                
                                EpubReaderBaseAttributedData *data = [[EpubReaderBaseAttributedData alloc]init];
                                data.tagName = childernNode.tagName;
                                data.className = childernNode.className;
                                data.range = NSMakeRange(attributedString.length, appendString.length);
                                [markArray addObject:data];
                                
                                [attributedString appendAttributedString:appendString];
                            }
                            [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                        }
                    }
                }
                else if ([childernNode.tagName isEqualToString:@"h6"]){
                    for (HTMLNode *node in childernNode.children) {
                        if ([node.tagName isEqualToString:@"text"]) {
                            NSString *content = node.content;
                            if (content) {
                                NSMutableAttributedString *appendString = [[NSMutableAttributedString alloc]initWithString:content];
                                
                                EpubReaderBaseAttributedData *data = [[EpubReaderBaseAttributedData alloc]init];
                                data.tagName = childernNode.tagName;
                                data.className = childernNode.className;
                                data.range = NSMakeRange(attributedString.length, appendString.length);
                                [markArray addObject:data];
                                
                                [attributedString appendAttributedString:appendString];
                            }
                            [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                        }
                    }
                }
                else if ([childernNode.tagName isEqualToString:@"b"]){
                    for (HTMLNode *node in childernNode.children) {
                        if ([node.tagName isEqualToString:@"text"]) {
                            NSString *content = node.content;
                            if (content) {
                                NSMutableAttributedString *appendString = [[NSMutableAttributedString alloc]initWithString:content];
                                
                                EpubReaderBaseAttributedData *data = [[EpubReaderBaseAttributedData alloc]init];
                                data.tagName = childernNode.tagName;
                                data.className = childernNode.className;
                                data.range = NSMakeRange(attributedString.length, appendString.length);
                                [markArray addObject:data];
                                
                                [attributedString appendAttributedString:appendString];
                            }
                            [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                        }
                        
                    }
                }
                
                else if ([childernNode.tagName isEqualToString:@"p"]){
                    for (HTMLNode *node in childernNode.children) {
                        if ([node.tagName isEqualToString:@"text"]) {
                            NSString *content = node.content;
                            if (content) {
                                NSMutableAttributedString *appendString = [[NSMutableAttributedString alloc]initWithString:content];
                                
                                EpubReaderBaseAttributedData *data = [[EpubReaderBaseAttributedData alloc]init];
                                data.tagName = childernNode.tagName;
                                data.className = childernNode.className;
                                data.range = NSMakeRange(attributedString.length, appendString.length);
                                [markArray addObject:data];
                                
                                [attributedString appendAttributedString:appendString];
                            }
                            [attributedString appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
                        }
                        else if ([node.tagName isEqualToString:@"img"]){
                            NSString *string = [node getAttributeNamed:@"src"];
                            NSString *imageSrc = [[creatDestinationPath() stringByAppendingPathComponent:@"OPS"]stringByAppendingPathComponent:string];
                            NSAttributedString *appendString = [self parseImageDataWithSrc:imageSrc];
                            
                            EpubReaderImageData *data = [[EpubReaderImageData alloc]init];
                            data.tagName = childernNode.tagName;
                            data.className = childernNode.className;
                            data.range = NSMakeRange(attributedString.length, appendString.length);
                            data.imageSrc = imageSrc;
                            [markArray addObject:data];
                            [attributedString appendAttributedString:appendString];
                        }
                        
                        
                    }
                }
            }
        }
    }
        return attributedString;
}
- (void)addCssStyleWithAttributedString:(NSMutableAttributedString *)attributedString cssStylesheet:(EpubCSSStyleSheet *)cssStylesheet markArray:(NSMutableArray *)markArray prefaceArray:(NSMutableArray *)prefaceArray keywordArray:(NSMutableArray *)keywordArray commentArray:(NSMutableArray *)commentArray lineArray:(NSMutableArray *)lineArray imageArray:(NSMutableArray *)imageArray
{
    for (EpubReaderBaseAttributedData *data in markArray) {
        if ([data isMemberOfClass:[EpubReaderImageData class]]){
            EpubReaderImageData *imageData = (EpubReaderImageData *)data;
            [imageArray addObject:imageData];
            
            NSAttributedString *replaceAttributeString = [self parseImageDataWithSrc:imageData.imageSrc];
            [attributedString replaceCharactersInRange:data.range withAttributedString:replaceAttributeString];
        }else if ([data isMemberOfClass:[EpubReaderBaseAttributedData class]]){
            if ([data.tagName hasPrefix:@"h"]){
                NSDictionary *cssAttribute = [cssStylesheet.styles objectForKey:data.tagName];
                NSDictionary *attribute = [EpubCssConverHelp convertWithAttribute:cssAttribute];
                EpubReaderStyleSetting *model = [[EpubReaderStyleSetting alloc]init];
                model.lineSpace = 0;
                CGFloat fontsize = [[attribute objectForKey:@"fontSize"] floatValue];
                CGFloat fontWidth = [[attribute objectForKey:@"fontWidth"]floatValue];
                
                if (fontsize > 0 && fontWidth > 0) {
                    model.font = [UIFont systemFontOfSize:fontsize weight:fontWidth];
                }
                else if (fontsize){
                    model.font = [UIFont boldSystemFontOfSize:fontsize];
                }
               
                NSInteger textAlignment = [[attribute objectForKey:@"textAlign"] integerValue];
                if (textAlignment) {
                    model.textAlignment = textAlignment;
                }
                model.fristlineindent = 0;
                NSMutableDictionary *attributes = [self attributesWithData:model];
                [attributedString addAttributes:attributes range:data.range];
            }else if ([data.tagName isEqualToString:@"p"]){
                NSDictionary *cssAttribute = [cssStylesheet.styles objectForKey:@"p"];
                NSDictionary *attribute = [EpubCssConverHelp convertWithAttribute:cssAttribute];
                EpubReaderStyleSetting *model = [[EpubReaderStyleSetting alloc]init];
                CGFloat fontsize = [[attribute objectForKey:@"fontSize"] floatValue];
                if (fontsize > 0) {
                    model.font = [UIFont systemFontOfSize:fontsize];
                }
                if (data.className.length > 0) {
                    NSDictionary *dict = [cssStylesheet.styles objectForKey:F(@".%@", data.className)];
                    NSDictionary *attribute = [EpubCssConverHelp convertWithAttribute:dict];
                    NSInteger textAlignment = [[attribute objectForKey:@"textAlign"] integerValue];
                    if (textAlignment) {
                        model.textAlignment = textAlignment;
                    }
                }
                
                NSMutableDictionary *attributes = [self attributesWithData:model];
                [attributedString addAttributes:attributes range:data.range];
            }else if ([data.tagName isEqualToString:@"b"]){
                NSDictionary *cssAttribute = [cssStylesheet.styles objectForKey:@"body"];
                NSDictionary *attribute = [EpubCssConverHelp convertWithAttribute:cssAttribute];
                EpubReaderStyleSetting *model = [[EpubReaderStyleSetting alloc]init];
                CGFloat fontsize = [[attribute objectForKey:@"fontSize"] floatValue];
                if (fontsize > 0) {
                    model.font = [UIFont boldSystemFontOfSize:fontsize];
                }
                NSMutableDictionary *attributes = [self attributesWithData:model];
                [attributedString addAttributes:attributes range:data.range];
            }
        }
    }
}

- (NSArray *)parserEpubBookWithAttributedString:(NSAttributedString *)attributedString prefaceArray:(NSArray *)prefaceArray keywordArray:(NSMutableArray *)keywordArray commentArray:(NSMutableArray *)commentArray lineArray:(NSMutableArray *)lineArray imageArray:(NSMutableArray *)imageArray
{
    CFRange textRange = CFRangeMake(0, 0);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIBezierPath *pathContent = [UIBezierPath bezierPathWithRect:CGRectMake(15, 0, screenSize.width - 30, screenSize.height - 70)];
    NSMutableArray *array = [NSMutableArray array];
    while (YES) {
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, pathContent.CGPath, NULL);
        CFRange visibleRange = CTFrameGetVisibleStringRange(frame);
        NSRange pageRange = NSMakeRange(visibleRange.location, visibleRange.length);
        textRange.location = visibleRange.location + visibleRange.length;
        EpubReaderData *data = [[EpubReaderData alloc]init];
        data.ctFrame = frame;
        data.pageRange = pageRange;
        
        NSMutableArray *pagePrefaceArray = [NSMutableArray array];
        NSMutableArray *pageKeywordArray = [NSMutableArray array];
        NSMutableArray *pageCommentArray = [NSMutableArray array];
        NSMutableArray *pageLinkArray = [NSMutableArray array];
        NSMutableArray *pageImgArray = [NSMutableArray array];
        
        for (EpubReaderPrefaceData *prefaceData in prefaceArray) {
            if (prefaceData.range.location >= visibleRange.location && prefaceData.range.location < visibleRange.location + visibleRange.length) {
                [pagePrefaceArray addObject:prefaceData];
            }
        }
        for (EpubReaderKeyWordData *keywordData in keywordArray) {
            if (keywordData.range.location >= visibleRange.location && keywordData.range.location < visibleRange.location + visibleRange.length) {
                [pageKeywordArray addObject:keywordData];
            }
        }
        for (EpubReaderCommentData *commentData in commentArray) {
            if (commentData.range.location >= visibleRange.location && commentData.range.location < visibleRange.location + visibleRange.length) {
                [pageCommentArray addObject:commentData];
            }
        }
        for (EpubReaderLineData *lineData in lineArray) {
            if (lineData.range.location >= visibleRange.location && lineData.range.location < visibleRange.location + visibleRange.length) {
                [pageLinkArray addObject:lineData];
            }
        }
        for (EpubReaderImageData *imageData in imageArray) {
            if (imageData.range.location >= visibleRange.location && imageData.range.location < visibleRange.location + visibleRange.length) {
                [pageImgArray addObject:imageData];
            }
        }
        if (pagePrefaceArray.count > 0) {
            data.prefaceArray = [pagePrefaceArray copy];
        }
        if (pageKeywordArray.count > 0) {
            data.keywordArray = [pageKeywordArray copy];
        }
        if (pageCommentArray.count > 0) {
            data.commentArray = [pageCommentArray copy];
        }
        if (pageLinkArray.count > 0) {
            data.lineArray = [pageLinkArray copy];
        }
        if (pageImgArray.count > 0) {
            data.imageArray = [pageImgArray copy];
        }
        [data computePosition];
        [array addObject:data];
        CFRelease(frame);
        if (visibleRange.length + visibleRange.location >= attributedString.length) {
            break;
        }
    }
    CFRelease(framesetter);
    return [array copy];
}

static CGFloat ascentCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"] intValue];
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void* ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] intValue];
}

- (NSMutableDictionary *)imageAttributes
{
    CGFloat lineSpacing = 0;
    CTParagraphStyleSetting LineSpacing;
    LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    LineSpacing.value = &lineSpacing;
    LineSpacing.valueSize = sizeof(CGFloat);
    
    //段落与段落之间间隔
    CGFloat paragraphspace = 5;
    CTParagraphStyleSetting paragraph;
    paragraph.spec = kCTParagraphStyleSpecifierParagraphSpacing;
    paragraph.value = &paragraphspace;
    paragraph.valueSize = sizeof(CGFloat);
    
    CTParagraphStyleSetting settings[] = {LineSpacing,paragraph};
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(settings, 1);
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    CFRelease(theParagraphRef);
    return dict;
}

- (NSAttributedString *)parseImageDataWithSrc:(NSString *)src
{
    UIImage *image = [UIImage imageWithContentsOfFile:src];
    CGSize size;
    CGFloat maxWith = [UIScreen mainScreen].bounds.size.width - 40;
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height - 80;
    if (image.size.width > maxWith && image.size.height > maxHeight) {
        if (image.size.width > image.size.height) {
            size = CGSizeMake(maxWith, maxWith * image.size.height / image.size.width);
        }else{
            size = CGSizeMake(maxHeight * image.size.width / image.size.height, maxHeight);
        }
    }else if (image.size.width > maxWith){
        size = CGSizeMake(maxWith, maxWith * image.size.height / image.size.width);
    }else if (image.size.height > maxHeight){
        size = CGSizeMake(maxHeight * image.size.width / image.size.height, maxHeight);
    }else{
        size = image.size;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@(size.width),@"width",@(size.height),@"height", nil];
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks,(__bridge void *)(dict));
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary * attributes = [self imageAttributes];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",content] attributes:attributes];
    [space addAttribute:ImageMark value:[NSNumber numberWithBool:YES] range:NSMakeRange(0, 1)];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}


@end

