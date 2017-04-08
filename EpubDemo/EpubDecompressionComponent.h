//
//  EpubDecompressionComponent.h
//  EpubDemo
//
//  Created by JennyC on 2017/4/8.
//  Copyright © 2017年 Jenny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZipArchive.h>
#import "Macro.h"
WQ_INLINE BOOL unarchiveFile(NSString *filePath,NSString *destinationPath) {
    ZipArchive *archive = [[ZipArchive alloc] init];
    BOOL result;
    if ([archive UnzipOpenFile:filePath]) {
        result = [archive UnzipFileTo:destinationPath overWrite:YES];
        if (result) {
            [archive UnzipCloseFile];
        }
    }
    return result;
}
