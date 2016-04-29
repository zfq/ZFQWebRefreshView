//
//  ZFQWebRefreshView.m
//  
//  下拉刷新控件
//
//  Created by zfq on 15/1/26.
//  Copyright (c) 2015年 zfq. All rights reserved.
//

#import "ZFQWebRefreshView.h"

#define ZFQ_webRefreshView_sys_version  [UIDevice currentDevice].systemVersion.floatValue

#define zfq_offset_y @"contentOffset"

@interface ZFQWebRefreshView()
{
    CGFloat ZFQOffsetY;
    CGFloat _originOffsetY;  //原生的scrollView的偏移量
    CGFloat _originInsertY;
    
    CGFloat radius;
    CGFloat centerX;
    CGFloat centerY;
    
    NSInteger lineCount;
    NSInteger refreshCount; //刷新次数
    
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
    
    NSTimer *myTimer;
    CGFloat lineAlpha[12];
}
@end

@implementation ZFQWebRefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化
        self.hasNavBcgImg = NO;
        self.usingSpring = NO;
//        _usingStoryboard = NO;
        lineCount = 0;
        a = 1;
        
        if (frame.size.width > frame.size.height) {
            radius = frame.size.height / 2.0f;
        } else {
            radius = frame.size.width / 2.0f;
        }
        centerX = frame.size.width/2.0f;
        centerY = frame.size.height/2.0f;
        _inRadius = radius / 2.0f;
        _lineColor = [UIColor lightGrayColor];
        [_lineColor getRed:&r green:&g blue:&b alpha:&a];
        
        for (NSInteger i=0;i<12;i++) {
            lineAlpha[i] = i * 0.08f;
        }
    }
    return self;
}

- (void)layoutSubviews
{
    if (self.frame.size.width > self.frame.size.height) {
        radius = self.frame.size.height / 2.0f;
    } else {
        radius = self.frame.size.width / 2.0f;
    }
    centerX = self.frame.size.width/2.0f;
    centerY = self.frame.size.height/2.0f;
    _inRadius = radius / 2.0f;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    [_scrollView removeObserver:self forKeyPath:zfq_offset_y];
    _scrollView = scrollView;
    [_scrollView addObserver:self forKeyPath:zfq_offset_y options:NSKeyValueObservingOptionNew context:nil];
    
    //保存初始状态的Offset和Insert
    _originOffsetY = scrollView.contentOffset.y;
    _originInsertY = scrollView.contentInset.top;
}

- (void)setHasNavBcgImg:(BOOL)hasNavBcgImg
{
    _hasNavBcgImg = hasNavBcgImg;
//    if (_hasNavBcgImg) {
//        ZFQOffsetY = 0;
//    } else {
        ZFQOffsetY = 64;
//    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGFloat angle;
    CGFloat s = 0;
    CGFloat c = 0;
    for (NSInteger i = 1; i <= lineCount; i ++)
    {
        angle = i * 0.523f;
        s = sinf(angle);
        c = cosf(angle);
        CGPoint beginPoint = CGPointMake(_inRadius * s, _inRadius * c);
        CGPoint endPoint = CGPointMake(radius * s, radius * c);
    
        CGContextMoveToPoint(context, centerX + beginPoint.x, centerY - beginPoint.y);
        CGContextAddLineToPoint(context, centerX + endPoint.x, centerY - endPoint.y);
        if (_refreshState == ZFQWebRefreshStateLoading) {
            a = 1.0 - ((refreshCount+12 - i) % 12) * 0.083; //1.0/12
        } else {
            [_lineColor set];
        }
        CGContextSetRGBStrokeColor(context, r, g, b, a);
        
        CGContextStrokePath(context);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (![keyPath isEqualToString:zfq_offset_y]) {
        return;
    }
    
    [self refreshViewDidScroll];
    
    if (_scrollView.isDragging == NO) {
        [self refreshViewEndDraging];
    }
    
//    NSLog(@"aa");
}
/*
- (void)refreshViewDidScroll
{
    //如果是正在刷新状态或者  朝上方向的偏移量 大于 ZFQOffsetY 就啥也不干
    if (_refreshState == ZFQWebRefreshStateLoading || _scrollView.contentOffset.y > -ZFQOffsetY) {
//    if (_refreshState == ZFQWebRefreshStateLoading) {
        _originOffsetY = _scrollView.contentOffset.y;
        return;
    }
    if (_refreshState == ZFQWebRefreshStateNormal) {
        a = 1;
        _refreshState = ZFQWebRefreshStatePulling;
    }
    
    // 应先计算 lineCount
    NSInteger offsetY = _scrollView.contentOffset.y;
    if (offsetY > -ZFQOffsetY) {
        return;
    }
    //保证ZFQOffsetY<0
    ZFQOffsetY = ZFQOffsetY > 0 ? -ZFQOffsetY : ZFQOffsetY;
    NSInteger tempA = - 20;
    
    if (offsetY > tempA) {
        return;
    } else {
        NSInteger tempB = 8;
        offsetY -= (tempA+tempB);
        offsetY = offsetY < 0 ? -offsetY : offsetY;
        lineCount = offsetY / tempB;
        if (lineCount >= 12) {
            lineCount = 12;
        }
    }
    [self setNeedsDisplay];
}
 */

- (void)refreshViewDidScroll
{
    //如果是正在刷新状态或者  朝上方向的偏移量 大于 ZFQOffsetY 就啥也不干
    if (_refreshState == ZFQWebRefreshStateLoading || _scrollView.contentOffset.y > -ZFQOffsetY) {
        _originOffsetY = _scrollView.contentOffset.y;
        return;
    }
    if (_refreshState == ZFQWebRefreshStateNormal) {
        a = 1;
        _refreshState = ZFQWebRefreshStatePulling;
    }
    
    // 应先计算 lineCount
    NSInteger offsetY = _scrollView.contentOffset.y;
    if (offsetY > -ZFQOffsetY) {
        return;
    }
    //保证ZFQOffsetY<0
    ZFQOffsetY = ZFQOffsetY > 0 ? -ZFQOffsetY : ZFQOffsetY;
    NSInteger tempA = ZFQOffsetY - 20;
    
    if (offsetY > tempA) {
        return;
    } else {
        NSInteger tempB = 8;
        offsetY -= (tempA+tempB);
        offsetY = offsetY < 0 ? -offsetY : offsetY;
        lineCount = offsetY / tempB;
        if (lineCount >= 12) {
            lineCount = 12;
        }
    }
    [self setNeedsDisplay];
}

- (void)refreshViewEndDraging
{
    if (_refreshState == ZFQWebRefreshStatePulling && lineCount >= 12) {
        [self setRefreshState:ZFQWebRefreshStateLoading];
    } else {
        if (_refreshState == ZFQWebRefreshStateLoading || _scrollView.contentOffset.y > -64) { //-64
            return;
        }
    }
    
    if (lineCount >= 12) {
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    CGFloat maxY = CGRectGetMaxY(self.frame);
                    ZFQOffsetY = ZFQOffsetY < 0 ? -ZFQOffsetY : ZFQOffsetY;
                    CGFloat aa = maxY + self.frame.origin.y - ZFQOffsetY;
                    [_scrollView setContentInset:UIEdgeInsetsMake(aa, 0, 0, 0)];
                } completion:nil];
                
                lineCount = 12;
                if (_refreshState != ZFQWebRefreshStateLoading) {
                    [self setRefreshState:ZFQWebRefreshStateLoading];
                }
                
                if (self.beginRefreshBlk != NULL) {
                    self.beginRefreshBlk(self);
                }
            });
    } else {
        [self setRefreshState:ZFQWebRefreshStatePulling];
    }
}

- (void)setRefreshState:(ZFQWebRefreshState)state
{
    _refreshState = state;
    switch (state) {
        case ZFQWebRefreshStateNormal: {
            [self setNeedsDisplay];
        } break;
        case ZFQWebRefreshStatePulling: {
            
        } break;
        case ZFQWebRefreshStateLoading: {
            /*
             在另一个队列中开启定时器，每隔0.1秒刷新一次
             alpha 从 0 - 1；
             */
            if (myTimer == nil) {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    myTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1]
                                                       interval:0.1 target:self selector:@selector(updateAlpha:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
                    [[NSRunLoop currentRunLoop] run];
                });
            }
            
        } break;
        default:
            break;
    }
}

- (void)updateAlpha:(NSTimer *)timer
{
    refreshCount += 1;
    [self setNeedsDisplay];
}

- (void)endRefreshing
{
    if (_scrollView.contentOffset.y <= 0) {
        [self dealWithScrollView:_scrollView];
    } else if (_refreshState == ZFQWebRefreshStateLoading) {
        [self dealWithScrollView:_scrollView];
    }
    
    [self setRefreshState:ZFQWebRefreshStateNormal];
    
    //暂停定时器，清理数据
    [myTimer invalidate];
    myTimer = nil;
    a = 0;
    lineCount = 0;
    refreshCount = 0;
}

- (void)dealWithScrollView:(UIScrollView *)scrollView
{
    if (self.hasNavBcgImg == NO) {
        [UIView animateWithDuration:0.25 animations:^{
            [scrollView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
        } completion:^(BOOL finished) {
            if (finished) {
                [scrollView setContentOffset:CGPointMake(0, -64) animated:NO];
            }
        }];
    } else {
        
        if (_usingSpring == NO) {
            [UIView animateWithDuration:0.25 animations:^{
                [scrollView setContentInset:UIEdgeInsetsMake(_originInsertY, 0, 0, 0)];
            } completion:^(BOOL finished) {
                if (finished) {
                    [scrollView setContentOffset:CGPointMake(0, _originOffsetY) animated:NO];
                }
            }];
        } else {
            [UIView animateWithDuration:1.f
                                  delay:0.f
                 usingSpringWithDamping:0.4f
                  initialSpringVelocity:0.8f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [scrollView setContentInset:UIEdgeInsetsMake(_originInsertY, 0, 0, 0)];
                             } completion:^(BOOL finished) {
                                 if (finished) {
                                     [scrollView setContentOffset:CGPointMake(0, _originOffsetY) animated:NO];
                                 }
                             }];
        }

    }

}

- (void)beginRefreshingWithAnimation:(BOOL)animation
{
    _originOffsetY = _scrollView.contentOffset.y;
    _originInsertY = _scrollView.contentInset.top;
    
//    if (ZFQ_webRefreshView_sys_version < 8.0f) {
//        originInsertY = 64;
//        originOffsetY = -64;
//    }
    
    _originInsertY = 64;
    _originOffsetY = -64;
    
    NSTimeInterval duration = animation == YES ? 0.25f : 0;
    [UIView animateWithDuration:duration animations:^{
        //设置一下contentInsert
//        CGFloat tempOffsetY = ZFQ_webRefreshView_sys_version < 7.1f ? -174 : -114;
        CGFloat tempOffsetY = _originOffsetY - 110;
        [_scrollView setContentOffset:CGPointMake(0, tempOffsetY)];
    } completion:^(BOOL finished) {
        if (finished) {
            [self refreshViewEndDraging];
        }
    }];
}

- (void)dealloc
{
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:zfq_offset_y];
    }
}
@end






