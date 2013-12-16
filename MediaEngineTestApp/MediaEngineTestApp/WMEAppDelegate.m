//
//  WMEAppDelegate.m
//  MediaEngineTestApp
//
//  Created by chu zhaozheng on 13-5-17.
//  Copyright (c) 2013年 video. All rights reserved.
//
//#import "WMEDemo.h"
#import "WMEAppDelegate.h"

@implementation WMEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    //ignore the SIGPIPE signal
    signal(SIGPIPE, SIG_IGN);

    //set the user database
    NSDictionary *userDefaultsValueDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"max_trace_level_preference", [NSNumber numberWithBool:NO], @"dump_data_enabled_preference", nil];
    _userDefaults = [NSUserDefaults standardUserDefaults];
    [self.userDefaults registerDefaults:userDefaultsValueDictionary];

    //set the preference updated notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePreferenceItem) name:NSUserDefaultsDidChangeNotification object:_userDefaults];
    
    NSInteger maxTraceLevel = [_userDefaults integerForKey:@"max_trace_level_preference"];
    BOOL dumpDataEnabled = [_userDefaults boolForKey:@"dump_data_enabled_preference"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *sharingFolderPath = [paths objectAtIndex:0];
    
    self.pWMEDataProcess = [WMEDataProcess instance];
    long ret = [self.pWMEDataProcess initWME];
    if (ret == WME_S_OK) {
        [self.pWMEDataProcess setTraceMaxLevel:maxTraceLevel];
        [self.pWMEDataProcess setDumpDataPath:[sharingFolderPath UTF8String]];
        [self.pWMEDataProcess setDumpDataEnabled:dumpDataEnabled];
    }
    
#ifdef TA_ENABLE
    //init TA
    self.pTAManager = new TAManager();
    self.pTAManager->CreateTANetwork();
#endif
    return YES;
}

//Notify from userdefault
- (void)updatePreferenceItem
{
    NSInteger maxTraceLevel = [_userDefaults integerForKey:@"max_trace_level_preference"];
    BOOL dumpDataEnabled = [_userDefaults boolForKey:@"dump_data_enabled_preference"];
    
    [[WMEDataProcess instance]setTraceMaxLevel:maxTraceLevel];
    [[WMEDataProcess instance]setDumpDataEnabled:dumpDataEnabled];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[WMEDataProcess instance]uninitWME];
}

@end
