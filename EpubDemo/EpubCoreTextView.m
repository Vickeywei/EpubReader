//
//  EpubCoreTextView.m
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import "EpubCoreTextView.h"
#import "EpubReaderBaseAttributedData.h"
#import "Macro.h"
#import <CoreText/CoreText.h>
#import "EpubReaderData.h"
@implementation EpubCoreTextView

-(void)setData:(EpubReaderData *)data
{
    _data = data;
    [self setNeedsDisplay];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupEvents];
    }
    return self;
}

- (void)setupEvents{
    UIGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetected:)];
    [self addGestureRecognizer:tapRecognizer];
}

- (void)tapGestureDetected:(UIGestureRecognizer *)recognizer
{
   if (self.data){
        CGPoint point = [recognizer locationInView:self];
        for (EpubReaderImageData * imageData in self.data.imageArray) {
            CGRect imageRect = imageData.imagePosition;
            CGPoint imagePosition = imageRect.origin;
            imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height;
            CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
            if (CGRectContainsPoint(rect, point)) {
                CGRect showImageRect = CGRectMake(imagePosition.x, rect.origin.y + self.frame.origin.y, rect.size.width, rect.size.height);
                [[NSNotificationCenter defaultCenter] postNotificationName:ImageClickActionNotification object:nil userInfo:@{ImageClick_ImageData:imageData,ImageClick_ShowImageRect:[NSValue valueWithCGRect:showImageRect]}];
                return;
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:ContentTouchActionNotification object:nil];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    if (self.data){
        
        for (EpubReaderImageData *imageData in self.data.imageArray) {
            UIImage *image = [UIImage imageWithContentsOfFile:imageData.imageSrc];
            if (image) {
                CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
            }
        }
        CTFrameDraw(self.data.ctFrame, context);
    }else{
        return;
    }
}


@end
