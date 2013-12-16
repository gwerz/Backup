//
//  WMEDataProcess.h
//  MediaEngineTestApp
//
//  Created by admin on 10/15/13.
//  Copyright (c) 2013 video. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "WmeEngine.h"
#import "DemoParameters.h"
#import "DemoClient.h"

//added by Alan for device platform detection
#define tDeviceUnknown							0
#define tDeviceNotSupport                       1
#define tDeviceSimulator						2

#define tDeviceiPhone3GS						10
#define tDeviceiPhone4G							11
#define tDeviceiPhone4GCDMA                     12
#define tDeviceiPhone4S                         13
#define tDeviceiPhone5                          14
#define tDeviceiPhoneFuture						19

#define tDeviceiPad1G							20
#define tDeviceiPad2GWiFi                       21
#define tDeviceiPad2GGSM                        22
#define tDeviceiPad2GCDMA                       23
#define tDeviceiPad3                            24
#define tDeviceiPad3ATT                         25
#define tDeviceiPad3CDMA                        26
#define tDeviceiPadFuture                       29

#define tDeviceiPod3G							30
#define tDeviceiPod4G							31
#define tDeviceiPodFuture						39

enum {
    WME_SENDING,
    WME_RECVING,
};


@interface WMEDataProcess : NSObject
{
    DemoClient *m_pWMEDemo;
    
    DemoClient::DevicePropertyList _audioInList;
    DemoClient::DevicePropertyList _audioOutList;
    DemoClient::DevicePropertyList _videoInList;
    
    DemoClient::AudioMediaCapabilityList _audioCapList;
    DemoClient::VideoMediaCapabilityList _videoCapList;
    DemoClient::DeviceCapabilityList _cameraCapList;
}

@property (retain) NSMutableArray *arrayAudioCapabilities;
@property (retain) NSMutableArray *arrayVideoCapabilities;
@property (retain) NSMutableArray *arrayCameraCapabilities;

@property (retain)  NSMutableArray *arrayMicDevices;
@property (retain)  NSMutableArray *arraySpeakerDevices;
@property (retain)  NSMutableArray *arrayCameraDevices;

//network property
@property (readwrite) BOOL   isHost;
@property (readwrite) BOOL   useICE;
@property (retain) NSString *jingleServerIP;
@property (retain) NSString *jingleServerPort;
@property (retain) NSString *stunServerIP;
@property (retain) NSString *stunServerPort;
@property (retain) NSString *hostIPAddress;
@property (retain) NSString *myName;
@property (retain) NSString *hostName;

//video property
//@property (readwrite) bool videoPreview;
@property (readwrite) BOOL bVideoSending;
@property (readwrite) NSInteger cameraIndex;
@property (readwrite) NSInteger cameraPosition;
@property (readwrite) NSInteger cameraCapIndex;
@property (readwrite) NSInteger videoCapIndex;
@property (readwrite) BOOL bKeepAspectRatio;

//audio property
@property (readwrite) BOOL bAudioSending;
@property (readwrite) NSInteger speakerIndex;
@property (readwrite) NSInteger speakerPosition;
@property (readwrite) NSInteger micIndex;
@property (readwrite) NSInteger audioCapIndex;

//render
@property (nonatomic) void* localRender;
@property (nonatomic) void* remoteRender;

//Method
+ (id)instance;

- (long)initWME;
- (void)uninitWME;
- (void)setTraceMaxLevel: (NSInteger)level;
- (void)setDumpDataEnabled:(BOOL)enable;
- (void)setDumpDataPath:(const char *)path;

- (void)setUISink: (backUISink *)sink;

- (void)queryAudioInDevices;
- (void)queryAudioOutDevices;
- (void)queryVideoInDevices;

- (void)queryAudioCapabilities;
- (void)queryVideoCapabilities;
- (void)queryVideoCameraCapabilities;

- (long)createAudioClient;
- (long)createVideoClient;
- (void)deleteAudioClient;
- (void)deleteVideoClient;

- (long)startAudioClient: (NSInteger)iType;
- (long)startVideoClient: (NSInteger)iType;
- (long)stopAudioClient: (NSInteger)iType;
- (long)stopVideoClient: (NSInteger)iType;

- (long)clickedConnect;
- (void)clickedDisconnect;


- (long)setVideoCameraDevice:(NSInteger)index;
- (void)switchCameraDevice;

- (long)setVideoEncodingParam:(NSInteger)index;
- (long)setVideoCameraParam:(NSInteger)index;
- (long)setVideoQualityType;
- (long)getVideoMediaCapability:(WmeVideoMediaCapability&)vMC;

- (void)setAudioCaptureDevice:(NSInteger)index;
- (long)setAudioEncodingParam:(NSInteger)index;
- (void)setAudioSpeaker:(NSInteger)index;
- (void)switchAudioSpeaker;

- (void)setRemoteRender:(void *)render;
- (void)setLocalRender:(void *)render;
- (long)setRenderAdaptiveAspectRatio:(BOOL)enable;
- (void)getVoiceLevel:(unsigned int &)level;

- (long)getVideoStatistics:(wme::WmeSessionStatistics &)statistics;
- (long)getAudioStatistics:(wme::WmeSessionStatistics &)statistics;




@end

