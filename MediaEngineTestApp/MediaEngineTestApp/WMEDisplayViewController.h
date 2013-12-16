//
//  WMEDisplayViewController.h
//  MediaEngineTestApp
//
//  Created by chu zhaozheng on 13-5-17.
//  Copyright (c) 2013年 video. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMERenderView.h"
#import "DemoParameters.h"
#import "WMEDataProcess.h"
#import "NotificationTransfer.h"


@interface WMEDisplayViewController : UIViewController<NotificationTranferDelegate>{
    BOOL bTopBarHiddenFlag;
    BOOL bIsPad;
    BOOL lastDeviceOrientationIsPortrait;
    
    UIAlertView *disconnectIndication;
}

@property (retain, nonatomic) WMEDataProcess *pWMEDataProcess;
@property (weak, nonatomic) IBOutlet UIButton *btSendVideo;
@property (weak, nonatomic) IBOutlet UIButton *btSendAudio;
@property (retain) WMERenderView *attendeeView;
@property (retain) WMERenderView *selfView;
@property (retain) UILabel *previewModeLabel;
- (IBAction)ButtonSendVideo:(id)sender;
- (IBAction)ButtonSendAudio:(id)sender;
- (IBAction)ButtonSwitchCamera:(id)sender;
- (IBAction)ButtonSwitchSpeaker:(id)sender;

//unwind segue
- (IBAction)SetSetting:(UIStoryboardSegue *)segue;

#ifdef TA_ENABLE
//for TA testing
@property (retain) NSTimer *updateVoiceLevelTimer;
@property (retain) UILabel *voiceLevelLabel;
- (void)TAStartShowVoiceLevel:(NSNotification*)notification;
- (void)TAStopShowVoiceLevel:(NSNotification*)notification;
#endif
@end
