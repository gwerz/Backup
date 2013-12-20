//
//  QQstyleTableViewViewController.h
//  QQstyleTableView
//
//  Created by xhan on 9/22/09.
//  Copyright In-Blue 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QQTableViewViewController : UIViewController < UITableViewDelegate , UITableViewDataSource , UIScrollViewDelegate > {
	UITableView* _tableView;
	NSDictionary *myDic;
	BOOL *flag;
	
	UIView *view1;
	UIView *view2;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic,retain) NSDictionary *myDic;

- (int)numberOfRowsInSection:(NSInteger)section;

@end


