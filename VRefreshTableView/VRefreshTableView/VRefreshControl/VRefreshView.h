//
//  VRefreshView.h
//  VRefreshTableView
//
//  Created by Vols on 14-7-20.
//  Copyright (c) 2014年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "VCircleView.h"

typedef NS_ENUM(NSUInteger, VPullRefreshState) {
  VPullRefreshPulling = 0,
	VPullRefreshNormal,
	VPullRefreshLoading,
};

@protocol VRefreshViewDelegate;

@interface VRefreshView : UIView{
	VPullRefreshState _state;
}

@property (nonatomic, strong) UILabel *lastUpdatedLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) VCircleView *circleView;

@property(nonatomic,assign) id <VRefreshViewDelegate> delegate;

- (void)refreshLastUpdatedDate;
- (void)vRefreshScrollViewWillBeginScroll:(UIScrollView *)scrollView;
- (void)vRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)vRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)vRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end

@protocol VRefreshViewDelegate <NSObject>

- (void)vRefreshViewDidTriggerRefresh:(VRefreshView*)view;
- (BOOL)vRefreshViewDataSourceIsLoading:(VRefreshView*)view;

@optional
- (NSDate*)vRefreshViewDataSourceLastUpdated:(VRefreshView*)view;

@end

