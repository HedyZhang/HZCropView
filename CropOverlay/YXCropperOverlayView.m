//
//  YXCropperOverlayView.m
//  Aifudao
//
//  Created by zhanghaidi on 2018/4/26.
//

#import "YXCropperOverlayView.h"

static CGFloat const kCornerSquareWidth = 30;

@interface YXCropperOverlayView ()

@property (nonatomic, strong) NSArray *horizontalGridLines;
@property (nonatomic, strong) NSArray *verticalGridLines;

@end
@implementation YXCropperOverlayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.borderWidth = 0.5;
        self.borderColor = [UIColor clearColor];
        self.minClearSize = CGSizeMake(60, 60);
    }
    return self;
}

#pragma mark - Setter

- (void)setClearRect:(CGRect)clearRect {
    _clearRect = clearRect;
    if (_clearRect.size.width < self.minClearSize.width) {
        _clearRect.size.width = self.minClearSize.width;
    }
    
    if (_clearRect.size.height < self.minClearSize.height) {
        _clearRect.size.height = self.minClearSize.height;
    }
}

#pragma mark - 拐角

- (void)createCornerWithContextRef:(CGContextRef)contextRef {
    CGContextSetFillColorWithColor(contextRef, [UIColor colorWithWhite:1 alpha:0.5].CGColor);
    
    CGContextSaveGState(contextRef);
    CGContextSetShouldAntialias(contextRef, NO);
    
    CGFloat margin = kCornerSquareWidth / 4;
    
    // Clear outside
    CGRect clip = CGRectOffset(self.clearRect, -margin * 0.4f, -margin * 0.4f);
    clip.size.width += margin * 0.8f;
    clip.size.height += margin * 0.8f;
    CGContextClipToRect(contextRef, clip);
    
    CGContextAddRect(contextRef, self.topLeftCorner);
    CGContextAddRect(contextRef, self.topRightCorner);
    CGContextAddRect(contextRef, self.bottomLeftCorner);
    CGContextAddRect(contextRef, self.bottomRightCorner);
    CGContextFillPath(contextRef);
    
    // Clear inside
    margin = kCornerSquareWidth / 8;
    clip = CGRectOffset(self.clearRect, margin, margin);
    clip.size.width -= margin * 2;
    clip.size.height -= margin * 2;
    CGContextClearRect(contextRef, clip);
    CGContextRestoreGState(contextRef);
}

#pragma - 网格

- (void)createGridWithContextRef:(CGContextRef)contextRef {
    CGPoint from, to;
    //垂直线
    CGContextSaveGState(contextRef);
    for (int i = 1; i < 3; i++) {
        from = CGPointMake(self.clearRect.origin.x + self.clearRect.size.width / 3.0f * i, self.clearRect.origin.y);
        to = CGPointMake(from.x, CGRectGetMaxY(self.clearRect));
        
        CGFloat lengths[] = {5, 2};
        CGContextSetLineDash(contextRef, 0, lengths, 2);
        CGContextMoveToPoint(contextRef, from.x, from.y);
        CGContextAddLineToPoint(contextRef, to.x, to.y);
        CGContextStrokePath(contextRef);
    }
    CGContextRestoreGState(contextRef);
    
    CGContextSaveGState(contextRef);
    //水平线
    for (int i = 1; i < 3; i++) {

        from = CGPointMake(self.clearRect.origin.x, self.clearRect.origin.y + self.clearRect.size.height / 3.0f * i);
        to = CGPointMake(CGRectGetMaxX(self.clearRect), from.y);
        CGFloat lengths[] = {5, 2};
        CGContextSetLineDash(contextRef, 0, lengths, 2);
        CGContextMoveToPoint(contextRef, from.x, from.y);
        CGContextAddLineToPoint(contextRef, to.x, to.y);
        CGContextStrokePath(contextRef);
    }
    CGContextRestoreGState(contextRef);
}

#pragma mark - 绘制
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(contextRef, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
    CGContextAddRect(contextRef, self.bounds);
    CGContextFillPath(contextRef);
    
    //透明区域 网线，拐角
    CGContextSaveGState(contextRef);
    [self createClearRectWithContextRef:contextRef];
    CGContextRestoreGState(contextRef);

    //画边框
    CGContextSaveGState(contextRef);
    CGContextSetStrokeColorWithColor(contextRef, self.borderColor.CGColor);
    CGContextSetLineWidth(contextRef, self.borderWidth);
    CGContextAddRect(contextRef, self.clearRect);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
}

#pragma mark - 透明区域

- (void)createClearRectWithContextRef:(CGContextRef)contextRef {
    CGContextClearRect(contextRef, self.clearRect);
    CGContextFillPath(contextRef);
    if (!self.cornerHidden) {
        [self createCornerWithContextRef:contextRef];
    }
    
    if (!self.gridHidden) {
        [self createGridWithContextRef:contextRef];
    }
    CGContextStrokePath(contextRef);
}

#pragma mark -

- (CGRect)edgeRect {
    return CGRectMake(CGRectGetMinX(self.clearRect) - kCornerSquareWidth / 2,
                      CGRectGetMinY(self.clearRect) - kCornerSquareWidth / 2,
                      CGRectGetWidth(self.clearRect) + kCornerSquareWidth,
                      CGRectGetHeight(self.clearRect) + kCornerSquareWidth);
}

- (CGRect)topLeftCorner {
    return CGRectMake(CGRectGetMinX(self.clearRect) - kCornerSquareWidth / 2,
                      CGRectGetMinY(self.clearRect) - kCornerSquareWidth / 2,
                      kCornerSquareWidth, kCornerSquareWidth);
}

- (CGRect)topRightCorner {
    return CGRectMake(CGRectGetMaxX(self.clearRect) - kCornerSquareWidth / 2,
                      CGRectGetMinY(self.clearRect) - kCornerSquareWidth / 2,
                      kCornerSquareWidth, kCornerSquareWidth);
}

- (CGRect)bottomLeftCorner {
    return CGRectMake(CGRectGetMinX(self.clearRect) - kCornerSquareWidth / 2,
                      CGRectGetMaxY(self.clearRect) - kCornerSquareWidth / 2,
                      kCornerSquareWidth, kCornerSquareWidth);
}

- (CGRect)bottomRightCorner {
    return CGRectMake(CGRectGetMaxX(self.clearRect) - kCornerSquareWidth / 2,
                      CGRectGetMaxY(self.clearRect) - kCornerSquareWidth / 2,
                      kCornerSquareWidth, kCornerSquareWidth);
}

- (CGRect)topEdgeRect {
    return CGRectMake(CGRectGetMinX(self.edgeRect) + kCornerSquareWidth,
                      CGRectGetMinY(self.edgeRect),
                      CGRectGetWidth(self.edgeRect) - kCornerSquareWidth * 2, kCornerSquareWidth);
}

- (CGRect)rightEdgeRect {
    return CGRectMake(CGRectGetMaxX(self.edgeRect) - kCornerSquareWidth,
                      CGRectGetMinY(self.edgeRect) + kCornerSquareWidth,
                      kCornerSquareWidth, CGRectGetHeight(self.edgeRect) - kCornerSquareWidth * 2);
}

- (CGRect)bottomEdgeRect {
    return CGRectMake(CGRectGetMinX(self.edgeRect) + kCornerSquareWidth,
                      CGRectGetMaxY(self.edgeRect) - kCornerSquareWidth,
                      CGRectGetWidth(self.edgeRect) - kCornerSquareWidth * 2, kCornerSquareWidth);
}

- (CGRect)leftEdgeRect {
    return CGRectMake(CGRectGetMinX(self.edgeRect),
                      CGRectGetMinY(self.edgeRect) + kCornerSquareWidth,
                      kCornerSquareWidth, CGRectGetHeight(self.edgeRect) - kCornerSquareWidth * 2);
}

- (BOOL)isEdgeContainsPoint:(CGPoint)point {
    return CGRectContainsPoint(self.topEdgeRect, point)
    || CGRectContainsPoint(self.rightEdgeRect, point)
    || CGRectContainsPoint(self.bottomEdgeRect, point)
    || CGRectContainsPoint(self.leftEdgeRect, point);
}

- (BOOL)isCornerContainsPoint:(CGPoint)point {
    return CGRectContainsPoint(self.topLeftCorner, point)
    || CGRectContainsPoint(self.topRightCorner, point)
    || CGRectContainsPoint(self.bottomLeftCorner, point)
    || CGRectContainsPoint(self.bottomRightCorner, point);
}

- (BOOL)isInRectPoint:(CGPoint)point {
    CGFloat x = self.clearRect.origin.x + 10;
    CGFloat xw = x + self.clearRect.size.width - 30;
    
    CGFloat y = self.clearRect.origin.y + 10;
    CGFloat yh = y + self.clearRect.size.height - 30;
    
    if (point.x > x && point.x < xw && point.y > y && point.y < yh) {
        return YES;
    }
    return NO;
}

@end
