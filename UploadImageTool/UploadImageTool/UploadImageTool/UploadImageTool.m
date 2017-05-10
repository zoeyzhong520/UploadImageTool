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
    
    uploadImageTool.uploadImageDelegate = aDelegate;
    fatherViewController = fatherVC;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册上传",@"相机拍照", nil];
    [sheet showInView:fatherVC.view];
}

#pragma mark -- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self fromPhotos];//从相册上传
    }else if (buttonIndex == 1) {
        [self createPhotoView];//相机拍照
    }
}

#pragma mark -- (相机和从相册中选择)
- (void)createPhotoView {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
        imagePC.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePC.delegate = self;
        imagePC.allowsEditing = YES;
        [fatherViewController presentViewController:imagePC animated:YES completion:^{
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备没有照相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//图片库方法(从设备的图片库中查找图片)
- (void)fromPhotos {
    UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
    imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePC.delegate = self;
    imagePC.allowsEditing = YES;
    [fatherViewController presentViewController:imagePC animated:YES completion:^{
    }];
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    //上传图片
    if (self.uploadImageDelegate && [self.uploadImageDelegate respondsToSelector:@selector(uploadImageToServerWithImage:)]) {
        [self.uploadImageDelegate uploadImageToServerWithImage:image];
    }
}

@end
