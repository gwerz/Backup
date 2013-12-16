//
//  DEMOViewController.h
//  demo
//
//  Created by zhaozheng on 13-10-18.
//  Copyright (c) 2013年 zhaozheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DEMOViewController : UIViewController
{
    BOOL bEnableFlag;
}
@property (strong, nonatomic) NSMutableArray *resFileArray;
@property (retain, nonatomic)UIAlertView *statusIndication;
@property (assign, nonatomic) NSUInteger selectedRow;

- (IBAction)startDecoderAll:(id)sender;
- (IBAction)startDecoderOne:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *currentSelectedFileTF;

//unwind segue
- (IBAction)unwindSegueForShowResourceViewController:(UIStoryboardSegue *)segue;
@end
