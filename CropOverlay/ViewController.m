//
//  ViewController.m
//  CropOverlay
//
//  Created by zhanghaidi on 2018/4/27.
//  Copyright © 2018年 zhanghaidi. All rights reserved.
//

#import "ViewController.h"
#import "YXCropperView.h"

@interface ViewController ()<YXCropperViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    YXCropperView *overlayView = [[YXCropperView alloc] initWithFrame:self.view.bounds];
    overlayView.delegate = self;
    overlayView.isEditingHiddenGrid = NO;
    overlayView.borderWidth = 0.5;
    overlayView.borderColor = [UIColor redColor];
    [self.view addSubview:overlayView];
}


- (void)confirmCropArea:(CGRect)cropRect {
    NSLog(@"crop Area = %@", NSStringFromCGRect(cropRect));
}

- (void)cancelCrop {
    NSLog(@"cancel crop");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
