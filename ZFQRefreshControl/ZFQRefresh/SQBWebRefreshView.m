//
//  SQBWebRefreshView.m
//  
//  下拉刷新控件
//
//  Created by wecash on 15/1/26.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import "SQBWebRefreshView.h"

#define sqb_webRefreshView_sys_version  [UIDevice currentDevice].systemVersion.floatValue

@interface SQBWebRefreshView()
{
    CGFloat sqbOffsetY;
    CGFloat originOffsetY;  //原生的scrollView的偏移量
    CGFloat originInsertY;
    
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

@implementation SQBWebRefreshView

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

- (void)setHasNavBcgImg:(BOOL)hasNavBcgImg
{
    _hasNavBcgImg = hasNavBcgImg;
//    if (_hasNavBcgImg) {
//        sqbOffsetY = 0;
//    } else {
        sqbOffsetY = 64;
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
        if (_refreshState == SQBWebRefreshStateLoading) {
            a = 1.0 - ((refreshCount+12 - i) % 12) * 0.083; //1.0/12
        } else {
            [_lineColor set];
        }
        CGContextSetRGBStrokeColor(context, r, g, b, a);
        
        CGContextStrokePath(context);
    }
}

- (void)refreshViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshState == SQBWebRefreshStateLoading || scrollView.contentOffset.y > -sqbOffsetY) {
        return;
    }
    if (_refreshState == SQBWebRefreshStateNormal) {
        a = 1;
        _refreshState = SQBWebRefreshStatePulling;
    }
    
    // 应先计算 lineCount
    NSInteger offsetY = scrollView.contentOffset.y;
    if (offsetY > -sqbOffsetY) {
        return;
    }
    //保证sqbOffsetY<0
    sqbOffsetY = sqbOffsetY > 0 ? -sqbOffsetY : sqbOffsetY;
    NSInteger tempA = sqbOffsetY - 20;  //sqbOffsetY - 20;
    
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

- (void)refreshViewEndDraging:(UIScrollView *)scrollView
{
    if (_refreshState == SQBWebRefreshStatePulling && lineCount >= 12) {
        [self setRefreshState:SQBWebRefreshStateLoading];
    } else {
        if (_refreshState == SQBWebRefreshStateLoading || scrollView.contentOffset.y > -64) { //-64
            return;
        }
    }
    
    if (lineCount >= 12) {
        
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ //延迟0.0秒防止抖动
                
                [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    CGFloat maxY = CGRectGetMaxY(self.frame);
                    sqbOffsetY = sqbOffsetY < 0 ? -sqbOffsetY : sqbOffsetY;
                    CGFloat aa = maxY + self.frame.origin.y - sqbOffsetY;
                    [scrollView setContentInset:UIEdgeInsetsMake(aa, 0, 0, 0)];
                } completion:nil];
                
                lineCount = 12;
                if (_refreshState != SQBWebRefreshStateLoading) {
                    [self setRefreshState:SQBWebRefreshStateLoading];
                }
                
                if (self.complectionBlk != NULL) {
                    self.complectionBlk(self);
                }
            });

    } else {
        [self setRefreshState:SQBWebRefreshStatePulling];
    }
}

- (void)setRefreshState:(SQBWebRefreshState)state
{
    _refreshState = state;
    switch (state) {
        case SQBWebRefreshStateNormal: {
            [self setNeedsDisplay];
        } break;
        case SQBWebRefreshStatePulling: {
            
        } break;
        case SQBWebRefreshStateLoading: {
            /*
             在另一个队列中开启定时器，每隔0.1秒刷新一次
             alpha 从 0 - 1；
             */
            if (myTimer == nil) { //DISPATCH_QUEUE_SERIAL
                dispatch_queue_t queue = dispatch_queue_create("com.shanqb.sqb", DISPATCH_QUEUE_SERIAL);
                //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                dispatch_async(queue, ^{
                    myTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1]
                                                       interval:0.1 target:self selector:@selector(updateAlpha:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes]; //NSDefaultRunLoopMode
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

- (void)refreshViewDidFinishLoading:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 0) {
        [self dealWithScrollView:scrollView];
    } else if (_refreshState == SQBWebRefreshStateLoading) {
        [self dealWithScrollView:scrollView];
    }
    
    [self setRefreshState:SQBWebRefreshStateNormal];
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
                [scrollView setContentInset:UIEdgeInsetsMake(originInsertY, 0, 0, 0)];
            } completion:^(BOOL finished) {
                if (finished) {
                    [scrollView setContentOffset:CGPointMake(0, originOffsetY) animated:NO];
                }
            }];
        } else {
            [UIView animateWithDuration:1.f
                                  delay:0.f
                 usingSpringWithDamping:0.4f
                  initialSpringVelocity:0.8f
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                             } completion:^(BOOL finished) {
                                 if (finished) {
                                     [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                                 }
                             }];
        }   //end if (_usingSpring)

    }

}

- (void)beginRefresh:(UIScrollView *)scrollView animation:(BOOL)animation
{

    originOffsetY = scrollView.contentOffset.y;
    originInsertY = scrollView.contentInset.top;
    
//    if (sqb_webRefreshView_sys_version < 8.0f) {
//        originInsertY = 64;
//        originOffsetY = -64;
//    }
    
    originInsertY = 64;
    originOffsetY = -64;
    
    NSTimeInterval duration = animation == YES ? 0.25f : 0;
    [UIView animateWithDuration:duration animations:^{
        //设置一下contentInsert
//        CGFloat tempOffsetY = sqb_webRefreshView_sys_version < 7.1f ? -174 : -114;
        CGFloat tempOffsetY = originOffsetY - 110;
        [scrollView setContentOffset:CGPointMake(0, tempOffsetY)];
    } completion:^(BOOL finished) {
        if (finished) {
            [self refreshViewEndDraging:scrollView];
        }
    }];
}
@end






