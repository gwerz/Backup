//
//  NotificationTransfer.h
//  MediaEngineTestApp
//
//  Created by chu zhaozheng on 13-9-12.
//  Copyright (c) 2013年 video. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DemoParameters.h"
#import "DemoClient.h"

class NativeNotificationSink;
@protocol NotificationTranferDelegate;

@interface NotificationTransfer : NSObject

@property (nonatomic) NativeNotificationSink *nativeNotificationSink;
@property (retain)  NSMutableArray *arrayObserver;

+ (NotificationTransfer *)instance;
- (void)addNotificationObserver:(id<NotificationTranferDelegate> )observer;
- (void)removeNotificationObserver:(id<NotificationTranferDelegate> )observer;
- (void)initNotificationTransfer;
- (void)networkDisconnect:(DEMO_MEDIA_TYPE) eType;
- (void)networkConnect:(DEMO_MEDIA_TYPE) eType;
- (void)onReceiveChannelID:(DEMO_MEDIA_TYPE) eType;
@end


class NativeNotificationSink : public backUISink
{
    void *_process;
public:
    explicit NativeNotificationSink(void *process)
    {
        _process = process;
    }
    
    virtual void networkDisconnectFromClient(DEMO_MEDIA_TYPE eType)
    {
        return_if_fail(_process != NULL);
        [((__bridge NotificationTransfer *)_process) networkDisconnect:eType];
    }
        
    virtual void connectRemoteFailureFromClient(DEMO_MEDIA_TYPE eType)
    {
        return_if_fail(_process != NULL);
        [((__bridge NotificationTransfer *)_process) networkDisconnect:eType];
    }
    
    virtual void connectRemoteOKFromClient(DEMO_MEDIA_TYPE mtype)
    {
        return_if_fail(_process != NULL);
        [((__bridge NotificationTransfer *)_process) networkConnect:mtype];
    }
        
    virtual void OnDeviceChanged(DeviceProperty *pDP, wme::WmeEventDataDeviceChanged &changeEvent)
    {
    }
        
    virtual void OnVolumeChange(wme::WmeEventDataVolumeChanged &changeEvent)
    {
    }
};


@protocol NotificationTranferDelegate <NSObject>

@optional
- (void)networkDisconnect:(DEMO_MEDIA_TYPE) eType;
- (void)networkConnect:(DEMO_MEDIA_TYPE) eType;
- (void)onReceiveChannelID:(DEMO_MEDIA_TYPE) eType;
@end
