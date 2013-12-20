//
//  QQstyleTableViewAppDelegate.h
//  QQstyleTableView
//
//  Created by xhan on 9/22/09.
//  Copyright In-Blue 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QQTableViewViewController;

@interface QQTableViewAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    QQTableViewViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet QQTableViewViewController *viewController;

@end

