//
//  EpubDestinationPath.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"
#import "EpubDecompressionComponent.h"
WQ_INLINE NSString * creatDestinationPath (){
    NSString *destinationPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"epub"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:destinationPath]) {
        NSError *error;
        BOOL creatResult = [fileManager createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (creatResult) {
            NSLog(@"创建成功");
        }
        else {
            NSLog(@"创建失败error:%@",error.localizedDescription);
        }
    }
    return destinationPath;
}

WQ_INLINE BOOL extractFile(){
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"每天懂一点好玩心理学" ofType:@"epub"];
    BOOL result = unarchiveFile(filePath,creatDestinationPath ());
    return result;
}



