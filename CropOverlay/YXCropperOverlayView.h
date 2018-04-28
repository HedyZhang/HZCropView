//
//  YXCropperOverlayView.h
//  Aifudao
//
//  Created by zhanghaidi on 2018/4/26.
//

#import <UIKit/UIKit.h>

@interface YXCropperOverlayView : UIView

//拐角
@property (nonatomic, readonly) CGRect topLeftCorner;
@property (nonatomic, readonly) CGRect topRightCorner;
@property (nonatomic, readonly) CGRect bottomLeftCorner;
@property (nonatomic, readonly) CGRect bottomRightCorner;
//边缘
@property (nonatomic, readonly) CGRect topEdgeRect;
@property (nonatomic, readonly) CGRect rightEdgeRect;
@property (nonatomic, readonly) CGRect bottomEdgeRect;
@property (nonatomic, readonly) CGRect leftEdgeRect;
//基准透明区域，不可赋初始值
@property (nonatomic, assign) CGRect clearRect;

@property (nonatomic, assign) CGSize minClearSize;

//是否显示拐角
@property (nonatomic, assign) BOOL cornerHidden;
//是否显示网线
@property (nonatomic, assign) BOOL gridHidden;

@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) UIColor *borderColor;


- (BOOL)isCornerContainsPoint:(CGPoint)point;

- (BOOL)isEdgeContainsPoint:(CGPoint)point;

- (BOOL)isInRectPoint:(CGPoint)point;

@end
