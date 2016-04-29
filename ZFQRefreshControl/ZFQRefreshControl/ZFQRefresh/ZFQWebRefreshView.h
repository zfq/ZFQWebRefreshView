//
//  ZFQRefreshView.h
//  
//  下拉刷新控件
//
//  Created by zfq on 15/1/26.
//  Copyright (c) 2015年 zfq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFQWebRefreshState) {
    ZFQWebRefreshStateNormal,   //not visible
    ZFQWebRefreshStatePulling,
    ZFQWebRefreshStateLoading
};

@interface ZFQWebRefreshView : UIView
{
    ZFQWebRefreshState _refreshState;
}

@property (nonatomic,strong) UIColor *lineColor;
@property (nonatomic) CGFloat inRadius;
@property (nonatomic) BOOL hasNavBcgImg;    //是否有导航栏背景图片，默认是NO
@property (nonatomic,copy) void (^beginRefreshBlk)(ZFQWebRefreshView *refreshView);
@property (nonatomic) BOOL usingSpring;     //是否使用弹性动画，默认是NO

@property (nonatomic,weak) UIScrollView *scrollView;

//- (instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)scrollView;

///开始刷新
- (void)beginRefreshingWithAnimation:(BOOL)animation;


///停止刷新
- (void)endRefreshing;

@end
