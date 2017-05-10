//
//  UploadImageTool.m
//  UploadImageTool
//
//  Created by JOE on 2017/5/10.
//  Copyright © 2017年 ZZJ. All rights reserved.
//

#import "UploadImageTool.h"

static UploadImageTool *uploadImageTool = nil;
@implementation UploadImageTool

+ (UploadImageTool *)shareUploadImageTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploadImageTool = [[UploadImageTool alloc] init];
    });
    return uploadImageTool;
}

- (void)showActionSheetInFatherViewController:(UIViewController *)fatherVC delegate:(id<ZZJUploadImageDelegate>)aDelegate {
    
}

#pragma mark -- UIActionSheetDelegate


@end
