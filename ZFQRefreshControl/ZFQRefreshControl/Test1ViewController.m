//
//  Test1ViewController.m
//  ZFQRefreshControl
//
//  Created by _ on 16/4/29.
//  Copyright © 2016年 zfq. All rights reserved.
//

#import "Test1ViewController.h"
#import "ZFQWebRefreshView.h"

@interface Test1ViewController ()
@property (nonatomic,strong) ZFQWebRefreshView *refreshView;
@end

@implementation Test1ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://wwww.baidu.com"]];
    [_myWebView loadRequest:req];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.refreshView.superview == nil) {
        _myWebView.backgroundColor = [UIColor whiteColor];
        UIView *webScrollView = _myWebView.subviews.firstObject;
        [_myWebView insertSubview:self.refreshView belowSubview:webScrollView];
    }
}

- (ZFQWebRefreshView *)refreshView
{
    if (_refreshView == nil) {
        float SQB_SYSTERM_VERSION = [UIDevice currentDevice].systemVersion.floatValue;
        CGFloat width = 30;
//        BOOL hasNavBcgImg = !self.navigationController.navigationBar.translucent;
        BOOL hasNavBcgImg = NO;
        CGFloat refreshViewOriginY = hasNavBcgImg ? 10 : (64 + 10);
        refreshViewOriginY = SQB_SYSTERM_VERSION < 7.1f ? 74 : refreshViewOriginY;
        CGRect refresViewFrame = CGRectMake((self.view.frame.size.width - width)/2.0f, refreshViewOriginY, width, width);
        _refreshView = [[ZFQWebRefreshView alloc] initWithFrame:refresViewFrame];
        _refreshView.backgroundColor = [UIColor clearColor];
        _refreshView.hasNavBcgImg = YES;
//        _refreshView.usingSpring = YES;
        _refreshView.scrollView = self.myWebView.scrollView;
        _refreshView.beginRefreshBlk = ^(ZFQWebRefreshView *rView) {
            NSLog(@"开始刷新");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"停止刷新");
                [rView endRefreshing];
            });
        };
    }
    return _refreshView;
}

@end
