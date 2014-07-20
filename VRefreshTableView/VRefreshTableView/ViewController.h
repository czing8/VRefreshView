//
//  ViewController.h
//  VRefreshTableView
//
//  Created by Vols on 14-7-20.
//  Copyright (c) 2014年 vols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VRefreshView.h"

@interface ViewController : UIViewController <VRefreshViewDelegate>

@property (nonatomic, strong)	VRefreshView *refreshView;
@property (nonatomic, assign)	BOOL reloading;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
