//
//  UploadImageTool.h
//  UploadImageTool
//
//  Created by JOE on 2017/5/10.
//  Copyright © 2017年 ZZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//把单例方法定义为宏，便于使用
#define ZZJUPLOAD_IMAGE [UploadImageTool shareUploadImageTool]

@protocol ZZJUploadImageDelegate <NSObject>

@optional

- (void)uploadImageToServerWithImage:(UIImage *)image;

@end

@interface UploadImageTool : NSObject<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIViewController *fatherViewController;
}

@property (nonatomic,weak) id <ZZJUploadImageDelegate>uploadImageDelegate;

//单例方法
+ (UploadImageTool *)shareUploadImageTool;

//弹出选项的方法
- (void)showActionSheetInFatherViewController:(UIViewController *)fatherVC delegate:(id<ZZJUploadImageDelegate>)aDelegate;

@end
