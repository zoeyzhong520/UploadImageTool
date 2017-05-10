//
//  ViewController.m
//  UploadImageTool
//
//  Created by JOE on 2017/5/10.
//  Copyright © 2017年 ZZJ. All rights reserved.
//

#import "ViewController.h"
#import "UploadImageTool.h"

@interface ViewController ()<ZZJUploadImageDelegate>

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setPage];
}

- (void)setPage {
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, 400);
    [button setTitle:@"上传图片" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:38];
    [button addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

//VC中上传图片的方法
- (void)selectPhoto {
    NSLog(@"上传图片");
    [ZZJUPLOAD_IMAGE showActionSheetInFatherViewController:self delegate:self];
}

//实现代理方法
#pragma mark -- ZZJUploadImageDelegate
- (void)uploadImageToServerWithImage:(UIImage *)image {
    //处理得到的image
    self.imageView.image = image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, self.view.bounds.size.width-100*2, 400)];
        _imageView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

@end
