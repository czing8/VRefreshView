//
//  ViewController.m
//  VRefreshTableView
//
//  Created by Vols on 14-7-20.
//  Copyright (c) 2014年 vols. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self.view addSubview:self.tableView];
  [self.view insertSubview:self.refreshView belowSubview:self.tableView];
	[_refreshView refreshLastUpdatedDate];

}

- (UITableView *)tableView{
  
  if (!_tableView) {
    CGRect frame = self.view.bounds;
    frame.origin.y += 20;
    frame.size.height -= 20;
    
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  }
  return _tableView;
}

- (VRefreshView *)refreshView{
  if (!_refreshView) {
    _refreshView = [[VRefreshView alloc] initWithFrame:self.tableView.frame];
		_refreshView.delegate = self;
  }
  return _refreshView;
}


#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 3;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString * identifier = @"ID";
  
  UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }
  
  for(UIView * view in cell.contentView.subviews){
    [view removeFromSuperview];
  }
  
  cell.selectionStyle = UITableViewCellSelectionStyleGray;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
  cell.textLabel.textColor = [UIColor colorWithWhite:0.293 alpha:1.000];
  cell.textLabel.font = [UIFont systemFontOfSize:15];
  cell.textLabel.text = @"asdfasd";
  
  return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSelector:@selector(deselect:) withObject:tableView afterDelay:0.2f];
}

- (void)deselect:(UITableView *)tableView
{
  [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}



- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshView vRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}




#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  [_refreshView vRefreshScrollViewWillBeginScroll:scrollView];
  
  

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshView vRefreshScrollViewDidScroll:scrollView];
  
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshView vRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - vRefreshViewDelegate Methods

- (void)vRefreshViewDidTriggerRefresh:(VRefreshView *)view
{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)vRefreshViewDataSourceIsLoading:(VRefreshView *)view{
	
	return _reloading; // should return if data source model is reloading

}

- (NSDate*)vRefreshViewDataSourceLastUpdated:(VRefreshView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}



- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}












@end
