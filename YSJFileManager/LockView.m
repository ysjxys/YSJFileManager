//
//  LockView.m
//  LockView
//
//  Created by ysj on 15/7/28.
//  Copyright (c) 2015年 ysj. All rights reserved.
//

#import "LockView.h"
#import "CircleBtn.h"
@interface LockView()
@property (nonatomic, strong) NSMutableArray *selectedBtnsArr;
@property (nonatomic, assign) CGPoint currentPoint;
@end
@implementation LockView

- (NSMutableArray *)selectedBtnsArr{
    if (!_selectedBtnsArr) {
        _selectedBtnsArr = [NSMutableArray array];
    }
    return _selectedBtnsArr;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    return self;
}

- (void)initView{
    for (int i = 0; i < 9; i++) {
        CircleBtn *btn = [CircleBtn buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [self addSubview:btn];
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    static CGFloat W = 74;
    static CGFloat H = 74;
    NSInteger lineCount = 3;
    CGFloat dist = (self.bounds.size.width - W * lineCount)/(lineCount + 1);
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[CircleBtn class]]) {
            CircleBtn *btn = (CircleBtn*)view;
            NSInteger btnNum = btn.tag;
            CGFloat X = btnNum % lineCount * (dist + W) + dist;
            CGFloat Y = btnNum / lineCount * (dist + H) + dist;
            btn.frame = CGRectMake(X, Y, W, H);
        }
    }
}

- (CGPoint)pointWithTouches:(NSSet *)touches{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:touch.view];
}

- (CircleBtn *)buttonWithPoint:(CGPoint)point{
    static CGFloat dist = 20;
    CGFloat W = 2 * dist;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[CircleBtn class]]) {
            CGFloat X = view.center.x - dist;
            CGFloat Y = view.center.y - dist;
            if (CGRectContainsPoint(CGRectMake(X, Y, W, W), point)) {
                return (CircleBtn*)view;
            }
        }
    }
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point = [self pointWithTouches:touches];
    CircleBtn *btn = [self buttonWithPoint:point];
    if (btn && !btn.selected) {
        btn.selected = YES;
        [self.selectedBtnsArr addObject:btn];
        [self setNeedsDisplay];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point = [self pointWithTouches:touches];
    CircleBtn *btn = [self buttonWithPoint:point];
    if (btn && !btn.selected) {
        btn.selected = YES;
        [self.selectedBtnsArr addObject:btn];
    }else{
        self.currentPoint = point;
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.selectedBtnsArr makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
    for (CircleBtn *btn in self.selectedBtnsArr) {
        [btn setSelected:NO];
    }
    
    NSMutableString *finishedPath = [NSMutableString string];
    for (CircleBtn *btn in self.selectedBtnsArr) {
        [finishedPath appendFormat:@"%ld",(long)btn.tag];
    }
    [self.delegate lockView:self didFinishedPath:finishedPath];
    
    [self.selectedBtnsArr removeAllObjects];
    self.currentPoint = CGPointZero;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect{
    if (self.selectedBtnsArr.count == 0) {
        return;
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < self.selectedBtnsArr.count; i++) {
        CircleBtn *btn = self.selectedBtnsArr[i];
        if (i == 0) {
            [path moveToPoint:btn.center];
        }else{
            [path addLineToPoint:btn.center];
        }
    }
    if (!CGPointEqualToPoint(self.currentPoint, CGPointZero)) {
        [path addLineToPoint:self.currentPoint];
    }
    
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = 8;
    [[UIColor colorWithRed:32/255.0 green:210/255.0 blue:254/255.0 alpha:0.5] set];
    [path stroke];
}


@end
