//
//  SQBWebRefreshView.h
//  
//  下拉刷新控件
//
//  Created by wecash on 15/1/26.
//  Copyright (c) 2015年 shanqb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SQBWebRefreshState) {
    SQBWebRefreshStateNormal,   //not visible
    SQBWebRefreshStatePulling,
    SQBWebRefreshStateLoading
};

@interface SQBWebRefreshView : UIView
{
    SQBWebRefreshState _refreshState;
}

@property (nonatomic,strong) UIColor *lineColor;
@property (nonatomic) CGFloat inRadius;
@property (nonatomic) BOOL hasNavBcgImg;    //是否有导航栏背景图片，默认是NO
@property (nonatomic,copy) void (^complectionBlk)(SQBWebRefreshView *refreshView);
@property (nonatomic) BOOL usingSpring;     //是否使用弹性动画，默认是NO

- (void)beginRefresh:(UIScrollView *)scrollView animation:(BOOL)animation;

- (void)refreshViewDidScroll:(UIScrollView *)scrollView;

- (void)refreshViewEndDraging:(UIScrollView *)scrollView;

- (void)refreshViewDidFinishLoading:(UIScrollView *)scrollView;

@end
