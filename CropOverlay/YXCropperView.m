//
//  YXCropperView.m
//  Aifudao
//
//  Created by zhanghaidi on 2018/4/26.
//

#import "YXCropperView.h"

static  CGFloat  const kButtonWidth = 25;

typedef NS_ENUM(NSUInteger, YXOverlayViewPanningMode) {
    YXOverlayViewPanningModeNone     = 0,
    YXOverlayViewPanningModeLeft     = 1 << 0,
    YXOverlayViewPanningModeRight    = 1 << 1,
    YXOverlayViewPanningModeTop      = 1 << 2,
    YXOverlayViewPanningModeBottom   = 1 << 3
};

@interface YXCropperView ()
@property (nonatomic, assign) YXOverlayViewPanningMode overlayViewPanningMode;
//是否是透明区域
@property (nonatomic, assign) BOOL isCleanRect;
//触摸的是否是透明区域中心,否则是透明区域中心
@property (nonatomic, assign) BOOL isCenterCleanRect;

@property (nonatomic, assign) CGPoint firstTouchedPoint;

@property (nonatomic, assign) CGRect cropOriginFrame;

@end


@implementation YXCropperView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panGestureRecognizer];
        
        self.overlayView = [[YXCropperOverlayView alloc] initWithFrame:self.bounds];
        self.overlayView.clearRect = CGRectMake((self.frame.size.width - 200) / 2.f, (self.frame.size.height - 200) / 2.f, 200, 200);
        self.overlayView.cornerHidden = YES;
        self.overlayView.gridHidden = YES;
        self.overlayView.borderColor = [UIColor blueColor];
        self.overlayView.borderWidth = 1;
        self.overlayView.minClearSize = CGSizeMake(100, 100);
        [self addSubview:_overlayView];
        [self.overlayView setNeedsDisplay];
        
        [self addSubview:self.okButton];
        [self addSubview:self.cancelButton];
        [self updateButtonFrameWithClearRect:self.overlayView.clearRect];
        
    }
    return self;
}

- (void)updateButtonFrameWithClearRect:(CGRect)clearRect {
    self.okButton.frame = CGRectMake(CGRectGetMaxX(clearRect) - kButtonWidth - self.overlayView.borderWidth, clearRect.origin.y + self.overlayView.borderWidth, kButtonWidth, kButtonWidth);
    self.cancelButton.frame = CGRectMake(CGRectGetMinX(self.okButton.frame) - kButtonWidth - 20, self.okButton.frame.origin.y, kButtonWidth, kButtonWidth);
}

#pragma mark - 拖动手势响应

- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.firstTouchedPoint = point;
        self.cropOriginFrame = self.overlayView.clearRect;
         self.overlayViewPanningMode = [self getOverlayViewPanningModeByPoint:self.firstTouchedPoint];

         if ([self.overlayView isInRectPoint:self.firstTouchedPoint]) {
             self.isCenterCleanRect = YES;
         } else {
             self.isCenterCleanRect = NO;
         }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (self.isCenterCleanRect) {
            self.overlayView.gridHidden = self.isEditingHiddenGrid;
        }
    } else {
         if (self.isCenterCleanRect) {
             self.overlayView.gridHidden = YES;
         }
    }

    if (self.isCenterCleanRect) {
        [self panCenterOverlayViewWithPoint:point];
    } else {
        [self panEdgeOverlayViewWithPoint:point];
    }
}

- (void)panCenterOverlayViewWithPoint:(CGPoint )point {
    CGRect newClearRect = self.cropOriginFrame;
    
    CGFloat width = self.overlayView.frame.size.width;
    CGFloat height = self.overlayView.frame.size.height;
    
    //计算当前点相对手指刚接触的屏幕点的差值
    CGFloat xDelta = ceilf(point.x - self.firstTouchedPoint.x);
    CGFloat yDelta = ceilf(point.y - self.firstTouchedPoint.y);
    
    newClearRect.origin.x += xDelta;
    newClearRect.origin.y += yDelta;
    
    //限制透明框的x、y不超过overlay的x、y
    if (newClearRect.origin.x <= 0) {
        newClearRect.origin.x = 0;
    } else if (newClearRect.origin.x + newClearRect.size.width >= width) {
        newClearRect.origin.x = width - newClearRect.size.width;
    }
    
    if (newClearRect.origin.y <= 0) {
        newClearRect.origin.y = 0;
    } else if (newClearRect.origin.y + newClearRect.size.height >= height) {
        newClearRect.origin.y = height - newClearRect.size.height;
    }
    
    self.overlayView.clearRect = newClearRect;
    [self updateButtonFrameWithClearRect:self.overlayView.clearRect];
    
    [self.overlayView setNeedsDisplay];
}

- (void)panEdgeOverlayViewWithPoint:(CGPoint )point {
    CGRect newClearRect = self.cropOriginFrame;
    
    CGFloat width = self.overlayView.frame.size.width;
    CGFloat height = self.overlayView.frame.size.height;
    
    //计算当前点相对手指刚接触的屏幕点的差值
    CGFloat xDelta = ceilf(point.x - self.firstTouchedPoint.x);
    CGFloat yDelta = ceilf(point.y - self.firstTouchedPoint.y);
    
    if (self.overlayViewPanningMode & YXOverlayViewPanningModeLeft) {
        newClearRect.size.width -= xDelta;
    } else if (self.overlayViewPanningMode & YXOverlayViewPanningModeRight) {
        newClearRect.size.width += xDelta;
    }
    
    if (self.overlayViewPanningMode & YXOverlayViewPanningModeTop) {
        newClearRect.size.height -= yDelta;
    } else if (self.overlayViewPanningMode & YXOverlayViewPanningModeBottom) {
        newClearRect.size.height += yDelta;
    }
    
    //限制透明框的宽高不超过overlay的宽高
    if (newClearRect.origin.x + newClearRect.size.width >= width) {
        newClearRect.size.width = width - newClearRect.origin.x;
    }
    
    if (newClearRect.origin.y + newClearRect.size.height >= height) {
        newClearRect.size.height = height - newClearRect.origin.y;
    }
    
    self.overlayView.clearRect = newClearRect;
    [self updateButtonFrameWithClearRect:self.overlayView.clearRect];

    [self.overlayView setNeedsDisplay];
}

#pragma mark - 蒙板手势状态
- (YXOverlayViewPanningMode)getOverlayViewPanningModeByPoint:(CGPoint)point {
    if (CGRectContainsPoint(self.overlayView.topLeftCorner, point)) {
        return (YXOverlayViewPanningModeLeft | YXOverlayViewPanningModeTop);
    } else if (CGRectContainsPoint(self.overlayView.topRightCorner, point)) {
        return (YXOverlayViewPanningModeRight | YXOverlayViewPanningModeTop);
    } else if (CGRectContainsPoint(self.overlayView.bottomLeftCorner, point)) {
        return (YXOverlayViewPanningModeLeft | YXOverlayViewPanningModeBottom);
    } else if (CGRectContainsPoint(self.overlayView.bottomRightCorner, point)) {
        return (YXOverlayViewPanningModeRight | YXOverlayViewPanningModeBottom);
    } else if (CGRectContainsPoint(self.overlayView.topEdgeRect, point)) {
        return YXOverlayViewPanningModeTop;
    } else if (CGRectContainsPoint(self.overlayView.rightEdgeRect, point)) {
        return YXOverlayViewPanningModeRight;
    } else if (CGRectContainsPoint(self.overlayView.bottomEdgeRect, point)) {
        return YXOverlayViewPanningModeBottom;
    } else if (CGRectContainsPoint(self.overlayView.leftEdgeRect, point)) {
        return YXOverlayViewPanningModeLeft;
    }
    return YXOverlayViewPanningModeNone;
}

#pragma mark - Button Actions

- (void)confirmCropRect {
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmCropArea:)]) {
        [self.delegate confirmCropArea:self.overlayView.clearRect];
    }
}

- (void)cancelCropAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelCrop)]) {
        [self.delegate cancelCrop];
    }
}


#pragma mark - Setter

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.overlayView.borderColor = _borderColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.overlayView.borderWidth = _borderWidth;
    [self updateButtonFrameWithClearRect:self.overlayView.clearRect];
}

#pragma mark - Getter

- (UIButton *)okButton {
    if (!_okButton) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _okButton.backgroundColor = [UIColor redColor];
        [_okButton addTarget:self action:@selector(confirmCropRect) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor greenColor];
        [_cancelButton addTarget:self action:@selector(cancelCropAction) forControlEvents:UIControlEventTouchUpInside];

    }
    return _cancelButton;
}


@end
