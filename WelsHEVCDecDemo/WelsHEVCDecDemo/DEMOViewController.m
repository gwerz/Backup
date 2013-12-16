//
//  DEMOViewController.m
//  demo
//
//  Created by zhaozheng on 13-10-18.
//  Copyright (c) 2013年 zhaozheng. All rights reserved.
//

#define ENDLESS_LOOP   //define to do the performance testing
#define NO_OUTPUT_MODE //define to disable the output yuv file

extern int decoder_main(int argc, char * argv[]);

#import "DEMOViewController.h"
#import "DEMOViewControllerShowResource.h"

@interface DEMOViewController ()

@end

@implementation DEMOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //Add the testing codes
    self.resFileArray = [[NSMutableArray alloc] init];
    self.selectedRow = 0;
    [self updateResourceArray];
    
    //Init the status indication window
    _statusIndication = [[UIAlertView alloc] initWithTitle: @"Decoding" message: @"Waiting the decoding" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: nil];
    
    if  ([self.resFileArray count] > self.selectedRow)
        self.currentSelectedFileTF.text = [[self.resFileArray objectAtIndex:self.selectedRow] lastPathComponent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startDecoderAll:(id)sender {
    bEnableFlag = YES;
    [_statusIndication show];
    [NSThread detachNewThreadSelector:@selector(processDecoderAll) toTarget:self withObject:nil];
}

- (IBAction)startDecoderOne:(id)sender {
    bEnableFlag = YES;
    [_statusIndication show];
    [NSThread detachNewThreadSelector:@selector(processDecoderOne) toTarget:self withObject:nil];
}
- (void)processDecoderAll
{
    [self updateResourceArray];
    if (YES == [self DoDecoderAll]) {
            [self performSelectorOnMainThread:@selector(showAlertWnd) withObject:nil waitUntilDone:NO];
    }
}
- (void)processDecoderOne
{
    if (YES == [self DoDecoderOne:self.selectedRow]) {
        [self performSelectorOnMainThread:@selector(showAlertWnd) withObject:nil waitUntilDone:NO];
    }
}

- (void)showAlertWnd
{
    [_statusIndication dismissWithClickedButtonIndex:0 animated:(BOOL)YES];
    [self showAlertWindowTitle:@"Successful" message: @"Decode is successful!"];
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
        bEnableFlag = NO;
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"segueShowResource"]) {
        [self updateResourceArray];
        UINavigationController *navigationController = [segue destinationViewController];
        DEMOViewControllerShowResource *ViewControllerShowResource = (DEMOViewControllerShowResource *)[navigationController topViewController];
        ViewControllerShowResource.resFileArray = self.resFileArray;
    }
}
 
//unwind segue
- (void)unwindSegueForShowResourceViewController:(UIStoryboardSegue *)segue
{
    DEMOViewControllerShowResource *ViewControllerShowResource = [segue sourceViewController];
    self.selectedRow = ViewControllerShowResource.selectedRow;
    if  ([self.resFileArray count] > self.selectedRow)
        self.currentSelectedFileTF.text = [[self.resFileArray objectAtIndex:self.selectedRow] lastPathComponent];
}

//**************************************************************************/
// Following codes is for demo testing input
//**************************************************************************/
- (BOOL) DoDecoderAll
{
    BOOL bResult;
    
    for (NSUInteger index=0; index<[self.resFileArray count]; index++) {
        if ((bResult = [self DoDecoderOne:index]) == NO) {
            return NO;
        }
    }
	
    return YES;
}
- (BOOL) DoDecoderOne:(NSUInteger)index
{
    
    char *argv[4];//0 for exe name, 1 for resource input, 2 for output yuvfile, 3, for thread number
    int  argc = 4; 
    
    NSString *fileName = [[self.resFileArray objectAtIndex:index] lastPathComponent];
    
    NSString *outputFileName = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"yuv"];
    
    NSString *outputFilePath = [[[self.resFileArray objectAtIndex:index] stringByDeletingLastPathComponent] stringByAppendingPathComponent:outputFileName];
    
    argv[0] = (char *)("hevcDecConsole.exe");//unused
    argv[1] = (char *)[[self.resFileArray objectAtIndex:index] UTF8String]; //input resouce file path
    argv[2] = (char *)[outputFilePath UTF8String]; //output file path
    argv[3] = (char *)("1"); //output file path
    
    if (bEnableFlag == NO) {
        return NO;
    }
    
    decoder_main(argc, argv);
    
	
    return YES;
}

- (void) updateResourceArray
{
    
    //Clear the resource array
    if ([self.resFileArray count] > 0) {
        [self.resFileArray removeAllObjects];
    }
    
    //get the sharing folder path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *sharingFolderPath = [paths objectAtIndex:0];
    
    //enumerate the h.264 files at sharing folder
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSDirectoryEnumerator *directoryEnumerator;
    //directoryEnumerator = [fileManager enumeratorAtPath:sharingFolderPath];
    
    //NSMutableString *h264Files;
    NSError *error;
    NSArray * directoryContents = [fileManager contentsOfDirectoryAtPath:sharingFolderPath error:&error];
    
    for (NSUInteger index=0; index < [directoryContents count]; index++) {
        NSString *fileName = [directoryContents objectAtIndex:index];
        
        if (([fileName hasSuffix:@"265"] == YES) ||
            ([fileName hasSuffix:@"h265"] == YES)||
            ([fileName hasSuffix:@"H265"] == YES))
        {
            [self.resFileArray addObject:[sharingFolderPath stringByAppendingPathComponent:fileName]];
            //NSLog(@"%@", [sharingFolderPath stringByAppendingPathComponent:fileName]);
            
        }
    }
}


@end
