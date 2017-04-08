//
//  EpubReaderData.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "EpubReaderData.h"
#import "Macro.h"
#import "EpubReaderBaseAttributedData.h"

@implementation EpubReaderBaseData
@end

@implementation EpubReaderData
- (void)setCtFrame:(CTFrameRef)ctFrame {
    if (_ctFrame != ctFrame) {
        if (_ctFrame != nil) {
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
    }
}

-(void)computePosition
{
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    NSUInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    int prefaceIndex = 0;
    int keywordIndex = 0;
    int commentIndex = 0;
    int lineIndex = 0;
    int imageIndex = 0;
    
    for (int i = 0; i < lineCount; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray * runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            if ([runAttributes objectForKey:IntroductionMark]) {
                if (prefaceIndex < self.prefaceArray.count) {
                    EpubReaderPrefaceData *prefaceData = [self.prefaceArray objectAtIndex:prefaceIndex];
                    prefaceData.leftLineRect = CGRectMake(runBounds.origin.x, runBounds.origin.y - 5, 3, runBounds.size.height + 5);
                    prefaceData.bottomLineRect = CGRectMake(runBounds.origin.x, runBounds.origin.y - 5, runBounds.origin.x + runBounds.size.width + 40, 1);
                    prefaceIndex++;
                }
            }else if ([runAttributes objectForKey:keywordMark]){
                if (keywordIndex < self.keywordArray.count) {
                    EpubReaderKeyWordData *keywordData = [self.keywordArray objectAtIndex:keywordIndex];
                    keywordData.rect = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                    keywordIndex ++;
                }
            }else if ([runAttributes objectForKey:summaryMark]){
                if (commentIndex < self.commentArray.count) {
                    EpubReaderCommentData *commentData = [self.commentArray objectAtIndex:commentIndex];
                    runBounds.size.width = runBounds.size.width + 4;
                    runBounds.size.height = runBounds.size.height + 4;
                    commentData.rect = CGRectOffset(runBounds, colRect.origin.x - 2, colRect.origin.y - 2);
                    commentIndex ++;
                }
            }else if ([runAttributes objectForKey:quoteLineMark]){
                if (lineIndex < self.lineArray.count) {
                    EpubReaderLineData *lineData = [self.lineArray objectAtIndex:lineIndex];
                    lineData.top = lineOrigins[i].y + ((ascent + descent) / 2);
                    lineIndex++;
                }
            }else if ([runAttributes objectForKey:ImageMark]){
                if (imageIndex < self.imageArray.count) {
                    colRect.origin = CGPointMake(([UIScreen mainScreen].bounds.size.width - runBounds.size.width) / 2, colRect.origin.y);
                    CGRect delegateBounds = CGRectOffset(runBounds, ([UIScreen mainScreen].bounds.size.width - runBounds.size.width) / 2, colRect.origin.y);
                    EpubReaderImageData *imageData = [self.imageArray objectAtIndex:imageIndex];
                    imageData.imagePosition = delegateBounds;
                    imageIndex++;
                }
            }
        }
    }
}


- (void)dealloc {
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

@end
