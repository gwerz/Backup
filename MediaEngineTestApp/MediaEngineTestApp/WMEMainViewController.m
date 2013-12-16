//
//  WMEViewController.m
//  MediaEngineTestApp
//
//  Created by chu zhaozheng on 13-5-17.
//  Copyright (c) 2013年 video. All rights reserved.
//

#import "WMEMainViewController.h"
#import "WMEDisplayViewController.h"
#import "WMEDataProcess.h"


@interface WMEMainViewController ()

@end

@implementation WMEMainViewController

//synthesize 
@synthesize scServerOrClient = _scServerOrClient;
@synthesize tfServerIP = _tfServerIP;
@synthesize lbServerIP = _lbServerIP;
@synthesize btConnect = _btConnect;
@synthesize btStartServer = _btStartServer;
@synthesize btLocalMode = _btLocalMode;

@synthesize statusIndication = _statusIndication;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initialize the WME data processing
    self.pWMEDataProcess = [WMEDataProcess instance];
	
    // Do any additional setup after loading the view, typically from a nib.
    [_scServerOrClient addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    _scServerOrClient.selectedSegmentIndex = 0;
    
    //Hidden the server IP item
    [_tfServerIP setHidden:YES];
    [_lbServerIP setHidden:YES];
    [_btConnect setHidden:YES];
    [_btLocalMode setHidden:YES];
    
    //Init the status indication window
    _statusIndication = [[UIAlertView alloc] initWithTitle: @"Connecting" message: @"Waiting the connection" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//text field delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.tfServerIP) {
        [textField resignFirstResponder];
    }
    return YES;
}


//For segmented Control
-(void)didChangeSegmentControl:(UISegmentedControl *)control
{
    //Server
    if (control.selectedSegmentIndex == 0) {
        //Hidden the server IP item
        [_tfServerIP setHidden:YES];
        [_lbServerIP setHidden:YES];
        [_btConnect setHidden:YES];
        [_btStartServer setHidden:NO];
        
    }
    //Client
    else if (control.selectedSegmentIndex == 1)
    {
        //show the server IP item
        [_tfServerIP setHidden:NO];
        [_lbServerIP setHidden:NO];
        [_btConnect setHidden:NO];
        [_btStartServer setHidden:YES];        
    }

}

//For button action
//For start server button
- (IBAction)ButtonStartServer:(id)sender
{
    [_statusIndication show];
    self.pWMEDataProcess.UseICE = NO;
    self.pWMEDataProcess.IsHost = YES;
    [self.pWMEDataProcess clickedConnect];
}

- (IBAction)TapBlankPlace:(id)sender {
    if (sender != self.tfServerIP) {
        [self.tfServerIP resignFirstResponder];
    }
}
//For connect button
- (IBAction)ButtonConnect:(id)sender
{
    [_statusIndication show];

    self.pWMEDataProcess.UseICE = NO;
    self.pWMEDataProcess.IsHost = NO;
    self.pWMEDataProcess.HostIPAddress = [_tfServerIP text];
    [self.pWMEDataProcess clickedConnect];
    
}
- (void)showAlertWnd
{
    [_statusIndication dismissWithClickedButtonIndex:0 animated:(BOOL)YES];
    [self showAlertWindowTitle:@"Successful" message: @"Connection is successful!"];
    [self performSegueWithIdentifier:@"DISPLAY_SEGUE" sender:self];
}

-(void)showAlertWindowTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView *someError = [[UIAlertView alloc] initWithTitle: title message: message delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [someError show];
}

//Delegate for alertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_statusIndication == alertView) {
        //TBD...
        //Force to exit from the connection
        [self.pWMEDataProcess clickedDisconnect];
    }
    
}


- (void)networkDisconnect
{

}
- (void)networkConnect
{
     [self performSelectorOnMainThread:@selector(showAlertWnd) withObject:nil waitUntilDone:NO];
}

@end
