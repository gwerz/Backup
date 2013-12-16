//
//  WMEDisplayViewController.m
//  MediaEngineTestApp
//
//  Created by chu zhaozheng on 13-5-17.
//  Copyright (c) 2013年 video. All rights reserved.
//

#import "WMEDisplayViewController.h"
#import "WMESettingViewController.h"
#import "WMEDataProcess.h"


@interface WMEDisplayViewController ()

@end

@implementation WMEDisplayViewController

@synthesize btSendVideo = _btSendVideo;
@synthesize btSendAudio = _btSendAudio;
@synthesize attendeeView = _attendeeView;
@synthesize selfView     = _selfView;
@synthesize previewModeLabel = _previewModeLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initialize the WME data processing
    self.pWMEDataProcess = [WMEDataProcess instance];
    
#ifdef TA_ENABLE
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TAStartShowVoiceLevel:) name:@"NOTIFICATION_AVSYNCSTART" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TAStopShowVoiceLevel:) name:@"NOTIFICATION_AVSYNCSTOP" object:nil];
#endif
    
    //Initial the last orientation flag
    lastDeviceOrientationIsPortrait = FALSE;
    
    //Check the device type
    bIsPad  = TRUE;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        bIsPad  = FALSE;
    }

    //Hide the top bar
    bTopBarHiddenFlag = TRUE;
    [super.navigationController setNavigationBarHidden:bTopBarHiddenFlag animated:TRUE];
    
    disconnectIndication = [[UIAlertView alloc] initWithTitle: @"Disconnect" message: @"Network disconnect!" delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
    
    //query the default data
    [self.pWMEDataProcess queryAudioInDevices];
    [self.pWMEDataProcess queryAudioOutDevices];
    [self.pWMEDataProcess queryAudioCapabilities];
    [self.pWMEDataProcess queryVideoInDevices];
    [self.pWMEDataProcess queryVideoCapabilities];
    
	// set the initial state
    self.pWMEDataProcess.bVideoSending = NO;
    self.pWMEDataProcess.bAudioSending = YES;
    self.pWMEDataProcess.bKeepAspectRatio = NO;
    
    // initial the video parameters
    [self.pWMEDataProcess setVideoQualityType];
    [self.pWMEDataProcess setRenderAdaptiveAspectRatio:self.pWMEDataProcess.bKeepAspectRatio];
    [self.pWMEDataProcess setVideoEncodingParam:self.pWMEDataProcess.videoCapIndex];
    [self.pWMEDataProcess setVideoCameraDevice:self.pWMEDataProcess.cameraIndex];
    [self.pWMEDataProcess setVideoCameraParam:self.pWMEDataProcess.cameraCapIndex];

    // initial the audio parameters
    [self.pWMEDataProcess setAudioSpeaker:self.pWMEDataProcess.speakerIndex];
    [self.pWMEDataProcess setAudioEncodingParam:self.pWMEDataProcess.audioCapIndex];
    
    /// default start video preview and recving
    [self.pWMEDataProcess startVideoClient:WME_SENDING];
    [self.pWMEDataProcess startVideoClient:WME_RECVING];
    
    /// default start audio sending & recvinv
    [self.pWMEDataProcess startAudioClient:WME_SENDING];
    [self.pWMEDataProcess startAudioClient:WME_RECVING];
    
    //Add the observer to notification centre
    [[NotificationTransfer instance] addNotificationObserver:self];

    //Create the view window
    _selfView = [[WMERenderView alloc] init];
    _selfView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_selfView];
    
    _attendeeView = [[WMERenderView alloc] init];
    _attendeeView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_attendeeView];
    
    _previewModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    [_selfView addSubview:_previewModeLabel];
    _previewModeLabel.textColor = [UIColor redColor];
    _previewModeLabel.backgroundColor = [UIColor clearColor];
    _previewModeLabel.hidden    = YES;
    _previewModeLabel.text = @"Preview";
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //Set the notification for device orientation change
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    //Add the notifier for application switch state between active and in-active
    [center addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //Add the notifier for orientation changed
    [center addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //Arrange the render window for relative device orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self updateRenderUIForPortrait];
        lastDeviceOrientationIsPortrait = TRUE;
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        [self updateRenderUIForLandscape];
        lastDeviceOrientationIsPortrait = FALSE;
    }
    else
    {
        NSLog(@"failed to get initial orientation");
    }

    if (self.pWMEDataProcess.bVideoSending == YES) {
        [_btSendVideo setTitle:@"Stop Video" forState:UIControlStateNormal];        
        [_previewModeLabel setHidden:TRUE];
    }
    else
    {
        [_btSendVideo setTitle:@"Start Video" forState:UIControlStateNormal];
        [_btSendVideo.titleLabel setTextColor:[UIColor redColor]];
        [_previewModeLabel setHidden:FALSE];
    }
    
    [self.pWMEDataProcess setRemoteRender:(void *)_attendeeView];
    [self.pWMEDataProcess setLocalRender:(void *)_selfView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //End the notification for device orientation changed
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    //Remove the observer
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [center removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //Remove the render window
    [self.pWMEDataProcess setRemoteRender:NULL];
    [self.pWMEDataProcess setLocalRender:NULL];
}


- (void)applicationWillResignActive
{
    //Remove the render window
    [self.pWMEDataProcess setLocalRender:NULL];
    [self.pWMEDataProcess setRemoteRender:NULL];
}

- (void)applicationDidBecomeActive
{
    //Arrange the render window for relative device orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self updateRenderUIForPortrait];
        lastDeviceOrientationIsPortrait = TRUE;
    }
    else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        [self updateRenderUIForLandscape];
        lastDeviceOrientationIsPortrait = FALSE;
    }
    else
    {
        NSLog(@"failed to get initial orientation");
    }

    //Add the render window
    if (self.pWMEDataProcess.bVideoSending == YES) {
        [_btSendVideo setTitle:@"Stop Video" forState:UIControlStateNormal];
        [_previewModeLabel setHidden:TRUE];
    }
    else
    {
        [_btSendVideo setTitle:@"Start Video" forState:UIControlStateNormal];
        [_btSendVideo.titleLabel setTextColor:[UIColor redColor]];
        [_previewModeLabel setHidden:FALSE];
    }
    
    [self.pWMEDataProcess setRemoteRender:(__bridge void *)_attendeeView];
    [self.pWMEDataProcess setLocalRender:(__bridge void *)_selfView];
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if ((UIDeviceOrientationIsPortrait(orientation)) && (!lastDeviceOrientationIsPortrait))
    {
        [self updateRenderUIForPortrait];
        lastDeviceOrientationIsPortrait = TRUE;
    }
    else if((UIDeviceOrientationIsLandscape(orientation))&& (lastDeviceOrientationIsPortrait))
    {
        [self updateRenderUIForLandscape];
        lastDeviceOrientationIsPortrait = FALSE;
    }
    else
    {
        return;
    }
    
    /// remove previous render
    [self.pWMEDataProcess setRemoteRender: NULL];
    [self.pWMEDataProcess setLocalRender:NULL];

    /// set the latest render
    [self.pWMEDataProcess setRemoteRender:(__bridge void *)_attendeeView];
    [self.pWMEDataProcess setLocalRender:(__bridge void *)_selfView];
}

//update the UI for orientation changed
- (void)updateRenderUIForLandscape
{
    float selfWidth,selfHeight, selfPositionX, selfPositionY,
          attendeeWidth,attendeeHeight, attendeePositionX, attendeePositionY;
    
    //Create window for self-view
    if (bIsPad == TRUE) {
        //for iPad landscape
        //attendee-window
        attendeeWidth = 640.0;
        attendeeHeight = 360.0;
        attendeePositionX = 100.0;
        attendeePositionY = 50.0;
        //self-window
        selfWidth = 320.0;
        selfHeight = 180.0;
        selfPositionX = attendeePositionX;
        selfPositionY = attendeePositionY+attendeeHeight+50;

    }
    else
    {
        //for iphone landscape
        //attendee-window
        attendeeWidth = 320.0;
        attendeeHeight = 180.0;
        attendeePositionX = 20.0;
        attendeePositionY = 10.0;
        //self-window
        selfWidth = 160;
        selfHeight = 90;
        selfPositionX = attendeePositionX;
        selfPositionY = attendeePositionY+attendeeHeight+10;

    }
    
    [_selfView setFrame:CGRectMake(selfPositionX, selfPositionY, selfWidth, selfHeight)];
    [_attendeeView setFrame:CGRectMake(attendeePositionX, attendeePositionY, attendeeWidth,attendeeHeight)];
    
}
- (void)updateRenderUIForPortrait
{
    float selfWidth,selfHeight, selfPositionX, selfPositionY,
    attendeeWidth,attendeeHeight, attendeePositionX, attendeePositionY;
    if (self.pWMEDataProcess.bKeepAspectRatio == NO) {
        //Create window for self-view
        if (bIsPad == TRUE) {
            //for iPad portrait
            //attendee-window
            attendeeWidth = 360.0;
            attendeeHeight = 640.0;
            attendeePositionX = 50.0;
            attendeePositionY = 100.0;
            //self-window
            selfWidth = 180.0;
            selfHeight = 320.0;
            selfPositionX = attendeePositionX+attendeeWidth+50;
            selfPositionY = attendeePositionY;

        }
        else
        {
            //for iphone portrait
            //attendee-window
            attendeeWidth = 180.0;
            attendeeHeight = 320.0;
            attendeePositionX = 15.0;
            attendeePositionY = 20.0;
            //self-window
            selfWidth = 90;
            selfHeight = 160;
            selfPositionX = attendeePositionX+attendeeWidth+15;
            selfPositionY = attendeePositionY;

        }
    }
    else{
        
        CGRect screenRect =  [[UIScreen mainScreen] bounds];
        
        //Create window for self-view
        if (bIsPad == TRUE) {
            //for iPad portrait
            //attendee-window
            attendeeWidth = 640.0;
            attendeeHeight = 360.0;
            attendeePositionX = (screenRect.size.width-attendeeWidth)/2;
            attendeePositionY = 100.0;
            //self-window
            selfWidth = 320.0;
            selfHeight = 180.0;
            selfPositionX = attendeePositionX;
            selfPositionY = attendeePositionY+attendeeHeight+100;

        }
        else
        {
            //for iphone portrait
            //attendee-window
            attendeeWidth = 320.0-16; //for satisfy the screen size
            attendeeHeight = 180.0-9;
            attendeePositionX = (screenRect.size.width-attendeeWidth)/2;
            attendeePositionY = 20.0;
            //self-window
            selfWidth = 160;
            selfHeight = 90;
            selfPositionX = attendeePositionX;
            selfPositionY = attendeePositionY+attendeeHeight+20;
        }
    }

    [_selfView setFrame:CGRectMake(selfPositionX, selfPositionY, selfWidth, selfHeight)];
    [_attendeeView setFrame:CGRectMake(attendeePositionX, attendeePositionY, attendeeWidth,attendeeHeight)];

}


- (void)networkDisconnect:(DEMO_MEDIA_TYPE) eType
{
    [disconnectIndication show];
    [[NotificationTransfer instance] removeNotificationObserver:self];
    
    if (self.pWMEDataProcess.bVideoSending == YES) {
        [self ButtonSendVideo:_btSendVideo];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ButtonSendVideo:(id)sender
{
    //stop current self-view render window
    [self.pWMEDataProcess setLocalRender:NULL];
    [self.pWMEDataProcess stopVideoClient:WME_SENDING];
    
    if (self.pWMEDataProcess.bVideoSending == NO) {
        self.pWMEDataProcess.bVideoSending = YES;
        //update UI
        [_btSendVideo setTitle:@"Stop Video" forState:UIControlStateNormal];
        [_previewModeLabel setHidden:TRUE];
    }
    else{
        self.pWMEDataProcess.bVideoSending = NO;
        //Update UI
        [_btSendVideo setTitle:@"Start Video" forState:UIControlStateNormal];
        [_previewModeLabel setHidden:FALSE];

    }
    //start video client using new sending state
    [self.pWMEDataProcess setLocalRender:(void *)_selfView];
    [self.pWMEDataProcess startVideoClient:WME_SENDING];

}
- (IBAction)ButtonSendAudio:(id)sender
{
    if (self.pWMEDataProcess.bAudioSending == NO) {
        self.pWMEDataProcess.bAudioSending = YES;
        //enable audio
        [self.pWMEDataProcess startAudioClient:WME_SENDING];
        [_btSendAudio setTitle:@"Stop Audio" forState:UIControlStateNormal];
    }
    else{
        self.pWMEDataProcess.bAudioSending = NO;
        //disable send audio
        [self.pWMEDataProcess stopAudioClient:WME_SENDING];
        [_btSendAudio setTitle:@"Start Audio" forState:UIControlStateNormal];
    }
}
- (IBAction)ButtonSwitchCamera:(id)sender
{
    [self.pWMEDataProcess switchCameraDevice];
}

- (IBAction)ButtonSwitchSpeaker:(id)sender {
    [self.pWMEDataProcess switchAudioSpeaker];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    //For set the parameters setting
    if ([[segue identifier] isEqualToString:@"settingSegue"]) {
        WMESettingViewController *settingViewController = [segue destinationViewController];
        settingViewController.selectedVideoCapabilitySetting = iDefaultVideoCapabilitySetting;
        settingViewController.selectedAudioCapabilitySetting = iDefaultAudioCapabilitySetting;
        settingViewController.selectedCameraCapabilitySetting = iDefaultCameraCapabilitySetting;
        settingViewController.bSendVideoState = bSendVideoState;
        settingViewController.bPortraitViewRotationEnable = bPortraitViewRotationEnable;
    }
     */
}

//unwind segue
- (IBAction)SetSetting:(UIStoryboardSegue *)segue
{
    
    if ([[segue identifier] isEqualToString:@"settingUnwindSegue"]) {
        WMESettingViewController *settingViewController = [segue sourceViewController];
        self.pWMEDataProcess.bKeepAspectRatio = settingViewController.bKeepAspectRatio;
    }
}

#pragma mark -
#pragma mark onClick
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  	bTopBarHiddenFlag=!bTopBarHiddenFlag;
	[super.navigationController setNavigationBarHidden:bTopBarHiddenFlag animated:TRUE];
	//[super.navigationController setToolbarHidden:isflage animated:TRUE];
}

#ifdef TA_ENABLE
//for TA testing
- (void)TAStartShowVoiceLevel:(NSNotification*)notification
{
    NSInteger interval = [[notification.userInfo objectForKey:@"interval"] integerValue];
    
    self.voiceLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 180, 50)];
    [_attendeeView addSubview:self.voiceLevelLabel];
    self.voiceLevelLabel.textColor = [UIColor greenColor];
    self.voiceLevelLabel.backgroundColor = [UIColor clearColor];
    [self.voiceLevelLabel setFont:[UIFont systemFontOfSize:25.0]];
    
    unsigned int level;
    [self.pWMEDataProcess getVoiceLevel:level];
    NSString *stringText = [[NSString alloc] initWithFormat:@"VoiceLevel:%d", level];
    self.voiceLevelLabel.text = stringText;
    
    self.updateVoiceLevelTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateVoiceLevel) userInfo:nil repeats:YES];
}

- (void)TAStopShowVoiceLevel:(NSNotification*)notification
{
    [self.updateVoiceLevelTimer invalidate];
    [self.voiceLevelLabel removeFromSuperview];
}

- (void)updateVoiceLevel
{
    unsigned int level;
    [self.pWMEDataProcess getVoiceLevel:level];
    
    NSString *stringText = [[NSString alloc] initWithFormat:@"VoiceLevel:%d", level];
    [self performSelectorOnMainThread:@selector(redrawUIforVoiceLevelLabel:) withObject:stringText waitUntilDone:NO];
    
}
- (void)redrawUIforVoiceLevelLabel:(NSString *)stringText
{    
    self.voiceLevelLabel.text = stringText;
    [self.voiceLevelLabel setNeedsDisplay];
}
#endif
@end
