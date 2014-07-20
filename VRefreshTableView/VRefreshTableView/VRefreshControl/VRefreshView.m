//
//  VRefreshView.m
//  VRefreshTableView
//
//  Created by Vols on 14-7-20.
//  Copyright (c) 2014年 vols. All rights reserved.
//

#import "VRefreshView.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

@interface VRefreshView ()

- (void)setState:(VPullRefreshState)aState;

@end

@implementation VRefreshView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
      self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
      self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
      
      [self addSubview:self.lastUpdatedLabel];
      [self addSubview:self.statusLabel];
      [self addSubview:self.circleView];
      [self addSubview:self.activityView];
      
      [self setState:VPullRefreshNormal];
    }

    return self;
}





- (void)setState:(VPullRefreshState)aState{
	
	switch (aState) {
		case VPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
//			[CATransaction begin];
//			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
////			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
//			[CATransaction commit];
			
			break;
		case VPullRefreshNormal:
			
			if (_state == VPullRefreshPulling) {
        //  nothing
        
			} else {
        //                _circleView.transform = CGAffineTransformIdentity;
        _circleView.progress = 0;
        [_circleView setNeedsDisplay];
      }
			
			_statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case VPullRefreshLoading:{

			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			[CATransaction commit];

      CABasicAnimation* rotate =  [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
      rotate.removedOnCompletion = FALSE;
      rotate.fillMode = kCAFillModeForwards;

      //Do a series of 5 quarter turns for a total of a 1.25 turns
      //(2PI is a full turn, so pi/2 is a quarter turn)
      [rotate setToValue: [NSNumber numberWithFloat: M_PI / 2]];
      rotate.repeatCount = 11;
      
      rotate.duration = 0.25;
      rotate.cumulative = TRUE;
      rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

      [_circleView.layer addAnimation:rotate forKey:@"rotateAnimation"];
    }
			break;
		default:
			break;
	}
	
	_state = aState;
}





- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(vRefreshViewDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate vRefreshViewDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"AM"];
		[formatter setPMSymbol:@"PM"];
		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}
}


#pragma mark ScrollView Methods

- (void)vRefreshScrollViewWillBeginScroll:(UIScrollView *)scrollView
{
  BOOL _loading = NO;
  if ([_delegate respondsToSelector:@selector(vRefreshViewDataSourceIsLoading:)]) {
    _loading = [_delegate vRefreshViewDataSourceIsLoading:self];
  }
  if (!_loading) {
    [self setState:VPullRefreshNormal];
  }
}

- (void)vRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (_state == VPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(vRefreshViewDataSourceIsLoading:)]) {
			_loading = [_delegate vRefreshViewDataSourceIsLoading:self];
		}
		
		if (_state == VPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:VPullRefreshNormal];
		} else if (_state == VPullRefreshNormal && scrollView.contentOffset.y < -15.0f && !_loading) {
      float moveY = fabsf(scrollView.contentOffset.y);
      if (moveY > 65)
        moveY = 65;
      _circleView.progress = (moveY-15) / (65-15);
      [_circleView setNeedsDisplay];
      
      if (scrollView.contentOffset.y < -65.0f) {
        [self setState:VPullRefreshPulling];
      }
    }
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}

- (void)vRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(vRefreshViewDataSourceIsLoading:)]) {
		_loading = [_delegate vRefreshViewDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(vRefreshViewDidTriggerRefresh:)]) {
			[_delegate vRefreshViewDidTriggerRefresh:self];
		}
		
		[self setState:VPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
}

- (void)vRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
  
  double delayInSeconds = 0.2;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [_circleView.layer removeAllAnimations];
  });
}

#pragma mark - properties

- (UILabel *)lastUpdatedLabel{
  if (!_lastUpdatedLabel) {
    CGRect frame = CGRectMake(0.0f, 10.0f, self.frame.size.width, 20.0f);
    _lastUpdatedLabel = [self createLabelWithFrame:frame fontSize:12.0f];
  }
  return _lastUpdatedLabel;
}

- (UILabel *)statusLabel{
  if (!_statusLabel) {
    CGRect frame = CGRectMake(0.0f, 28.0f, self.frame.size.width, 20.0f);
    _statusLabel = [self createLabelWithFrame:frame fontSize:13.0f];
  }
  return _statusLabel;
}

- (VCircleView *)circleView{
  if (!_circleView) {
    _circleView = [[VCircleView alloc] initWithFrame:CGRectMake(10, 5, 35, 35)];
  }
  return _circleView;
}

- (UIActivityIndicatorView *)activityView{

  if (!_activityView) {
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake(25.0f, self.frame.size.height - 38.0f, 20.0f, 20.0f);
  }
  return _activityView;
}

#pragma mark - helper

- (UILabel *)createLabelWithFrame:(CGRect)frame fontSize:(float)fontSize{
  UILabel * label = [[UILabel alloc] initWithFrame:frame];
  label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  label.font = [UIFont systemFontOfSize:fontSize];
  label.textColor = TEXT_COLOR;
  label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
  label.shadowOffset = CGSizeMake(0.0f, 1.0f);
  label.backgroundColor = [UIColor clearColor];
  label.textAlignment = NSTextAlignmentCenter;
  return label;
}

#pragma mark - Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_lastUpdatedLabel = nil;
}

@end
