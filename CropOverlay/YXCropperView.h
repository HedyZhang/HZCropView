//
//  YXCropperView.h
//  Aifudao
//
//  Created by zhanghaidi on 2018/4/26.
//

#import <UIKit/UIKit.h>
#import "YXCropperOverlayView.h"

@protocol YXCropperViewDelegate<NSObject>

- (void)confirmCropArea:(CGRect)cropRect;
- (void)cancelCrop;

@end


@interface YXCropperView : UIView

@property (nonatomic, strong) YXCropperOverlayView *overlayView;

@property (nonatomic, weak) id<YXCropperViewDelegate> delegate;

@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *cancelButton;

//在
@property (nonatomic, assign) BOOL isEditingHiddenGrid;

@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;

@end
