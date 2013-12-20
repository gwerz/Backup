//
//  QQstyleTableViewViewController.m
//  QQstyleTableView
//
//  Created by xhan on 9/22/09.
//  Copyright In-Blue 2009. All rights reserved.
//

#import "QQTableViewViewController.h"

@implementation QQTableViewViewController

@synthesize tableView = _tableView;
@synthesize myDic;

////////////////////////////////////////////////////////////////////////////////////////
// NSObject 
- (void)dealloc {
	free(flag);
    [_tableView release], _tableView = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, 480)  style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.rowHeight = 50;
	_tableView.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
	_tableView.separatorColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
	[self.view addSubview:_tableView];
	
	NSArray *array1 = [[NSArray alloc] initWithObjects:@"诸葛亮",@"张飞",@"赵云",@"威严",nil];
	NSArray *array2 = [[NSArray alloc] initWithObjects:@"司马懿",@"郭嘉",@"典伟",@"寻",@"曹仁",nil];
	NSArray *array3 = [[NSArray alloc] initWithObjects:@"关羽",@"赵云",nil];
	NSArray *array4 = [[NSArray alloc] initWithObjects:@"马呆",@"张合",nil];
	
	myDic = [[NSDictionary alloc] initWithObjectsAndKeys:array1,@"我的兄弟",
			 array2,@"魏国大将",
			 array3,@"我的最爱",
			 array4,@"最爱小兵",nil];
	
    flag = (BOOL*)malloc([[myDic allKeys] count]*sizeof(BOOL*));  
    memset(flag, NO, sizeof(flag)); 
}

////////////////////////////////////////////////////////////////////////////////////////
// 
#pragma mark Table view  delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[myDic allKeys] count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	NSString *str = [[myDic valueForKey:[[myDic allKeys] objectAtIndex:[indexPath section]]] objectAtIndex:indexPath.row];
	//label = (UILabel *)[cell.contentView viewWithTag:101];
	cell.imageView.image = [UIImage imageNamed:@"102.png"];
	cell.textLabel.text = str;
	cell.detailTextLabel.text = @"cocoaChina 会员";
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	view1 = nil;
	view2 = nil;
	view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
	view1.backgroundColor = [UIColor colorWithRed:0.9 green:0.95 blue:0.9 alpha:1.0];
	
	view2 = [[UIView alloc] initWithFrame:CGRectMake(2, 1, 320, 30)];
	view2.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
	[view1 addSubview:view2];
	
	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 70, 30)];
	label1.backgroundColor = [UIColor clearColor];
	label1.text = [[myDic allKeys] objectAtIndex:section];
	[view2 addSubview:label1];
	[label1 release];
	
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 50, 30)];
	label2.backgroundColor = [UIColor clearColor];
	label2.text = [NSString stringWithFormat:@"(%d/%d)",section,[[myDic valueForKey:[[myDic allKeys] objectAtIndex:section]] count]];
	[view2 addSubview:label2];
	[label2 release];
	
	UIButton *abtn = [UIButton buttonWithType:UIButtonTypeCustom];
	abtn.backgroundColor = [UIColor clearColor];
	abtn.frame = CGRectMake(5, 1, 23, 27);
	[abtn setBackgroundImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
	[abtn setBackgroundImage:[UIImage imageNamed:@"click1.png"] forState:UIControlStateHighlighted];
	abtn.tag = section;
	[abtn addTarget:self action:@selector(headerClicked:) forControlEvents:UIControlEventTouchUpInside];
	[view2 addSubview:abtn];
	return view1;
}

////////////////////////////////////////////////////////////////////////////////////////
// 
-(void)headerClicked:(id)sender
{
	int sectionIndex = ((UIButton*)sender).tag;
	UIButton *btn = (UIButton *)sender;
	flag[sectionIndex] = !flag[sectionIndex];
	if(flag[sectionIndex])
	{
		btn.selected = YES;
	}
	else {
		btn.selected = NO;
	}

	[_tableView reloadData];
}

- (int)numberOfRowsInSection:(NSInteger)section
{
	if (flag[section]) {
		return [[myDic valueForKey:[[myDic allKeys] objectAtIndex:section]] count];
	}
	else {
		return 0;
	}
}

@end

