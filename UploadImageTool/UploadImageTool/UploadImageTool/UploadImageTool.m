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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [sheet showInView:fatherVC.view];
}

#pragma mark -- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self createPhotoView];//拍照
    }else if (buttonIndex == 1) {
        [self fromPhotos];//从相册选择
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
    
    /*
     UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePC];
     popover.popoverContentSize = CGSizeMake(600, 800);//弹出窗口大小，如果屏幕画不下，会挤小的。这个值默认是320x1100
     CGRect popoverRect = CGRectMake(0, screenHeight-200, screenWidth, 200);
     //popoverRect的中心点是用来画箭头的，如果中心点如果出了屏幕，系统会优化到窗口边缘
     //上面的矩形坐标是以这个view为参考的
     [popover presentPopoverFromRect:popoverRect inView:fatherViewController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
     */
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSLog(@"%@",info);
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *portraitImg = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self saveImageToIphone:portraitImg];
    
    //png -> jpg
    NSData *data;
    if (UIImagePNGRepresentation(portraitImg) == nil) {
        data = UIImageJPEGRepresentation(portraitImg, 1);
    }else{
        data = UIImagePNGRepresentation(portraitImg);
    }
    float length = [data length]/1024;
    NSLog(@"图片压缩前的大小：%f",length);
    
    //先判断宽高哪个短用哪个来做截取标准
    CGImageRef cgRef = portraitImg.CGImage;
    if (portraitImg.size.width > portraitImg.size.height) {
        CGImageRef imageRef = CGImageCreateWithImageInRect(cgRef, CGRectMake((portraitImg.size.width-portraitImg.size.height)/2, 0, portraitImg.size.width, portraitImg.size.width));
        UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
        portraitImg = thumbScale;
    }else{
        CGImageRef imageRef = CGImageCreateWithImageInRect(cgRef, CGRectMake(0, (portraitImg.size.height-portraitImg.size.width)/2, portraitImg.size.height, portraitImg.size.height));
        UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
        portraitImg = thumbScale;
    }
    
    UIImage *scaledImage = [self scaleToSize:portraitImg size:CGSizeMake(portraitImg.size.width*300/portraitImg.size.height, 300)];
    
    NSData *scaledImageData = UIImagePNGRepresentation(scaledImage);
    float scaledLenth = [scaledImageData length] / 1024;
    NSLog(@"图片压缩后的大小：%f", scaledLenth);
    
    //上传图片
    if (self.uploadImageDelegate && [self.uploadImageDelegate respondsToSelector:@selector(uploadImageToServerWithImage:)]) {
        [self.uploadImageDelegate uploadImageToServerWithImage:scaledImage];
    }
}

//压缩图片
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

///保存图片到相册
- (void)saveImageToIphone:(UIImage *)image {
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

//回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    
    NSLog(@"%@", msg);
    
    /*
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
     [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
     
     }]];
     [fatherViewController showViewController:alert sender:nil];
     */
}


@end
