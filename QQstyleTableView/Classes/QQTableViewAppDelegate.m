//
//  QQstyleTableViewAppDelegate.m
//  QQstyleTableView
//
//  Created by xhan on 9/22/09.
//  Copyright In-Blue 2009. All rights reserved.
//

#import "QQTableViewAppDelegate.h"
#import "QQTableViewViewController.h"

@implementation QQTableViewAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch  
	viewController = [[QQTableViewViewController alloc] init];
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
