//
//  WMEDataProcess.m
//  MediaEngineTestApp
//
//  Created by admin on 10/15/13.
//  Copyright (c) 2013 video. All rights reserved.
//
#import <sys/sysctl.h>

#import "WMEDataProcess.h"
#import "DemoParameters.h"
#import "DemoClient.h"


typedef struct
{
    WmeVideoRawType type;
    const char *string;
}FORMAT_MAP_INFO;

const static FORMAT_MAP_INFO kFormatMapInfo[] = {
    {WmeVideoUnknown,    "Unknown"},
    {WmeI420,            "I420"   },
    {WmeYV12,            "YV12"   },
    {WmeYUY2,            "YUY2"   },
    {WmeRGB24,           "RGB24"   },
    {WmeBGR24,           "BGR24"   },
    {WmeRGB24Flip,       "RGB24Flip"   },
    {WmeBGR24Flip,       "BGR24Flip"   },
    {WmeRGBA32,          "RGBA32"   },
    {WmeBGRA32,          "BGRA32"   },
    {WmeARGB32,          "ARGB32"   },
    {WmeABGR32,          "ABGR32"   },
    {WmeRGBA32Flip,      "RGBA32Flip"   },
    {WmeBGRA32Flip,      "BGRA32Flip"   },
    {WmeARGB32Flip,      "ARGB32Flip"   },
    {WmeABGR32Flip,      "ABGR32Flip"   },
};


@implementation WMEDataProcess


+ (WMEDataProcess *)instance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc]init];
    });
    return _sharedInstance;
}

- (long)initWME
{
    _arrayAudioCapabilities = [[NSMutableArray alloc] init];
    _arrayVideoCapabilities = [[NSMutableArray alloc] init];
    _arrayCameraCapabilities = [[NSMutableArray alloc]init];
    
    _arraySpeakerDevices = [[NSMutableArray alloc] init];
    _arrayMicDevices = [[NSMutableArray alloc] init];
    _arrayCameraDevices = [[NSMutableArray alloc] init];
    
    _isHost = FALSE;
    _useICE = FALSE;
    
    _cameraIndex = 0;
    _micIndex = 0;
    _speakerIndex = 0;
    
    _audioCapIndex = 0;
    _videoCapIndex = 0;
    _cameraCapIndex = 0;
    
    _bVideoSending = NO;
    _localRender = NULL;
    _remoteRender = NULL;
    _bKeepAspectRatio = NO;

    //init WME demo
    m_pWMEDemo = new DemoClient(NULL);
    m_pWMEDemo->Init(WME_TRACE_LEVEL_INFO);
    
    //init KVO observer
    [self initKVO];
    
    return WME_S_OK;
}

- (void)initKVO
{
    [self addObserver:self forKeyPath:@"audioCapIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"speakerIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"videoCapIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"cameraIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"cameraCapIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"bKeepAspectRatio" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id newValue = [change valueForKey:@"new"];
    
    if ([keyPath isEqualToString:@"audioCapIndex"]) {
        [self setAudioEncodingParam:[newValue integerValue]];
    }
    else if ([keyPath isEqualToString:@"speakerIndex"])
    {
        [self setAudioSpeaker:[newValue integerValue]];
    }
    else if ([keyPath isEqualToString:@"videoCapIndex"])
    {
        [self setVideoEncodingParam:[newValue integerValue]];
    }
    else if ([keyPath isEqualToString:@"cameraIndex"])
    {
        [self setVideoCameraDevice:[newValue integerValue]];
    }
    else if ([keyPath isEqualToString:@"cameraCapIndex"])
    {
        [self setVideoCameraParam:[newValue integerValue]];
    }
    else if ([keyPath isEqualToString:@"bKeepAspectRatio"])
    {
        [self setRenderAdaptiveAspectRatio:[newValue boolValue]];
    }

    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)uninitWME
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->UnInit();
    
    [_arrayAudioCapabilities removeAllObjects];
    [_arrayVideoCapabilities removeAllObjects];
    [_arrayCameraCapabilities removeAllObjects];
    
    [_arraySpeakerDevices removeAllObjects];
    [_arrayMicDevices removeAllObjects];
    [_arraySpeakerDevices removeAllObjects];
    
    m_pWMEDemo->ClearDeviceList(DEMO_MEDIA_AUDIO, _audioInList);
    m_pWMEDemo->ClearDeviceList(DEMO_MEDIA_AUDIO, _audioOutList);
    m_pWMEDemo->ClearDeviceList(DEMO_MEDIA_VIDEO, _videoInList);
    m_pWMEDemo->ClearDeviceCapabilities(DEV_TYPE_CAMERA, _cameraCapList);
    
    _audioCapList.clear();
    _videoCapList.clear();
    
    SAFE_DELETE(m_pWMEDemo);
}




- (void)setTraceMaxLevel: (int)level
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->SetTraceMaxLevel((WmeTraceLevel)level);
}
- (void)setDumpDataEnabled:(BOOL)enable
{
    return_if_fail(m_pWMEDemo != NULL);
    m_pWMEDemo->SetDumpDataEnabled(enable);
    
}
- (void)setDumpDataPath:(const char *)path
{
    return_if_fail(m_pWMEDemo != NULL);
    m_pWMEDemo->SetDumpDataPath(path);
    
}
- (void)setUISink:(backUISink *)sink
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->SetUISink(sink);
}

- (void)queryAudioInDevices
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->ClearDeviceList(DEMO_MEDIA_AUDIO, _audioInList);
    m_pWMEDemo->GetDeviceList(DEMO_MEDIA_AUDIO, DEV_TYPE_MIC, _audioInList);
    
    /// audio mic device list
    [_arrayMicDevices removeAllObjects];
    int defaultIndex = 0;
    for (int k=0; k < _audioInList.size(); k++) {
        DeviceProperty *dev = &(_audioInList.at(k));
        if (dev->is_default_dev) {
            defaultIndex = k;
        }
        [_arrayMicDevices  addObject:[[NSString alloc] initWithCString:dev->dev_name encoding:NSASCIIStringEncoding]];
    }
    _micIndex = defaultIndex;
}

- (void)queryAudioOutDevices
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->ClearDeviceList(DEMO_MEDIA_AUDIO, _audioOutList);
    m_pWMEDemo->GetDeviceList(DEMO_MEDIA_AUDIO, DEV_TYPE_SPEAKER, _audioOutList);
    
    /// audio speaker device list
    [_arraySpeakerDevices removeAllObjects];
    int defaultIndex = 0;
    int defaultPosition = DEV_POSITION_UNKNOWN;
    for (int k=0; k < _audioOutList.size(); k++) {
        DeviceProperty *dev = &(_audioOutList.at(k));
        if (dev->is_default_dev) {
            defaultIndex = k;
            defaultPosition = dev->position;
        }
        [_arraySpeakerDevices  addObject:[[NSString alloc] initWithCString:dev->dev_name encoding:NSASCIIStringEncoding]];
    }
    _speakerIndex = defaultIndex;
    _speakerPosition = defaultPosition;
}

- (void)queryVideoInDevices
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->ClearDeviceList(DEMO_MEDIA_VIDEO, _videoInList);
    m_pWMEDemo->GetDeviceList(DEMO_MEDIA_VIDEO, DEV_TYPE_CAMERA, _videoInList);
    
    /// video device list
    [_arrayCameraDevices removeAllObjects];
    int defaultIndex = 0;
    int defaultPosition = DEV_POSITION_UNKNOWN;
    for (int k=0; k < _videoInList.size(); k++) {
        DeviceProperty *dev = &(_videoInList.at(k));
        if (dev->is_default_dev) {
            defaultIndex = k;
            defaultPosition = dev->position;
        }
        [_arrayCameraDevices  addObject:[[NSString alloc] initWithCString:dev->dev_name encoding:NSASCIIStringEncoding]];
    }
    _cameraIndex = defaultIndex;
    _cameraPosition = defaultPosition;
}

- (void)queryAudioCapabilities
{
    return_if_fail(m_pWMEDemo != NULL);
    
    _audioCapList.clear();
    m_pWMEDemo->GetMediaCapabilities(DEMO_MEDIA_AUDIO, &_audioCapList);
    
    /// audio cap list
    [_arrayAudioCapabilities removeAllObjects];
    int defaultIndex = 0;
    for (int k=0; k < _audioCapList.size(); k++) {
        WmeAudioMediaCapability *cap = &(_audioCapList.at(k));
        if (cap->eCodecType == WmeCodecType_OPUS) {
            defaultIndex = k;
        }
        char strFmt[128];
        sprintf(strFmt, "%s, sample freq: %dKHz, bitrate: %dKbps",
                cap->stdname, cap->clockrate/1000, cap->rate/1000);
        [_arrayAudioCapabilities addObject:[[NSString alloc] initWithCString:strFmt encoding:NSASCIIStringEncoding]];
    }
    _audioCapIndex = defaultIndex;
}

- (void)queryVideoCapabilities
{
    return_if_fail(m_pWMEDemo != NULL);
    
    _videoCapList.clear();
    m_pWMEDemo->GetMediaCapabilities(DEMO_MEDIA_VIDEO, &_videoCapList);
    
    /// video cap list
    [_arrayVideoCapabilities removeAllObjects];
    int defaultIndex = 0;
    for (int k=0; k < _videoCapList.size(); k++) {
        WmeVideoMediaCapability *cap = &(_videoCapList.at(k));
        if (cap->eCodecType == WmeCodecType_Unknown) {
            continue;
        }
        
        if (cap->eCodecType == WmeCodecType_SVC && cap->height == 360) {
            defaultIndex = k;
        }
        
        float fps = cap->frame_layer[cap->frame_layer_number-1] * 1.0 / 100;
        char strFmt[128];
        snprintf(strFmt, 128, "%s, %dx%d@%1.ffps", kWmeVideoCodecTag[cap->eCodecType-WmeCodecType_AVC], (int)cap->width, (int)cap->height, fps);
        [_arrayVideoCapabilities addObject:[[NSString alloc] initWithCString:strFmt encoding:NSASCIIStringEncoding]];
    }
    _videoCapIndex = defaultIndex;
}

- (void)queryVideoCameraCapabilities
{
    return_if_fail(m_pWMEDemo != NULL);
    
    if (_cameraIndex > _videoInList.size()) {
        return;
    }
    
    DeviceProperty *dev = &(_videoInList.at(_cameraIndex));
    if (dev->dev == NULL) {
        return;
    }
    
    /// camera capability list
    m_pWMEDemo->ClearDeviceCapabilities(DEV_TYPE_CAMERA, _cameraCapList);
    m_pWMEDemo->GetDeviceCapabilities(DEV_TYPE_CAMERA, dev->dev, _cameraCapList);
    
    /// 
    [_arrayCameraCapabilities removeAllObjects];
    int defaultIndex = 0;
    bool bfind = false;
    for (int k=0; k < _cameraCapList.size(); k++) {
        WmeDeviceCapability *pDC = &(_cameraCapList.at(k));
        WmeCameraCapability *pCC = (WmeCameraCapability *)pDC->pCapalibity;
        
        const char *string = NULL;
        for (int i=0; i<sizeof(kFormatMapInfo)/sizeof(FORMAT_MAP_INFO); i++) {
            if (kFormatMapInfo[i].type == pCC->type) {
                string = kFormatMapInfo[i].string;
                break;
            }
        }
        if (string == NULL) {
            continue;
        }
        
        if (pCC->width >= 640 && pCC->height >= 360 && !bfind) {
            defaultIndex = k;
            bfind = true;
        }
        
        char info[128];
        snprintf(info, 128, "%s, %ldx%ld", string, pCC->width, pCC->height);
        [_arrayCameraCapabilities addObject:[[NSString alloc]initWithCString:info encoding:NSASCIIStringEncoding]];
    }
    _cameraCapIndex = defaultIndex;
}

- (long)createAudioClient
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    m_pWMEDemo->CreateMediaClient(DEMO_MEDIA_AUDIO);
    return WME_S_OK;
}

- (long)createVideoClient
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    m_pWMEDemo->CreateMediaClient(DEMO_MEDIA_VIDEO);
    return WME_S_OK;
}

- (void)deleteAudioClient
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->DeleteMediaClient(DEMO_MEDIA_AUDIO);
}

- (void)deleteVideoClient
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->DeleteMediaClient(DEMO_MEDIA_VIDEO);
}

- (long)startAudioClient: (int)iType
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    long ret = WME_E_FAIL;
    if (iType == WME_SENDING) {
        if (_bAudioSending == YES) {
            m_pWMEDemo->StartMediaSending(DEMO_MEDIA_AUDIO);
        }
        ret = m_pWMEDemo->StartMediaTrack(DEMO_MEDIA_AUDIO, DEMO_LOCAL_TRACK);
    }else {
        ret = m_pWMEDemo->StartMediaTrack(DEMO_MEDIA_AUDIO, DEMO_REMOTE_TRACK);
    }
    return ret;
}

- (long)startVideoClient: (int)iType
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    long ret = WME_E_FAIL;
    
    if (iType == WME_SENDING) {        
        if (_bVideoSending) {
            m_pWMEDemo->StartMediaSending(DEMO_MEDIA_VIDEO);
            ret = m_pWMEDemo->StartMediaTrack(DEMO_MEDIA_VIDEO, DEMO_LOCAL_TRACK);
        }else {
            ret = m_pWMEDemo->StartMediaTrack(DEMO_MEDIA_VIDEO, DEMO_PREVIEW_TRACK);
        }
    }else {
        ret = m_pWMEDemo->StartMediaTrack(DEMO_MEDIA_VIDEO, DEMO_REMOTE_TRACK);
    }
    return ret;
}

- (long)stopAudioClient: (int)iType
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    long ret = WME_E_FAIL;
    if (iType == WME_SENDING) {
        m_pWMEDemo->StopMediaSending(DEMO_MEDIA_AUDIO);
        ret = m_pWMEDemo->StopMediaTrack(DEMO_MEDIA_AUDIO, DEMO_LOCAL_TRACK);
    }else {
        ret = m_pWMEDemo->StopMediaTrack(DEMO_MEDIA_AUDIO, DEMO_REMOTE_TRACK);
    }
    return ret;
}

- (long)stopVideoClient: (int)iType
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);

    long ret = WME_E_FAIL;
    if (iType == WME_SENDING) {
        if (_bVideoSending){
            m_pWMEDemo->StopMediaSending(DEMO_MEDIA_VIDEO);
            ret = m_pWMEDemo->StopMediaTrack(DEMO_MEDIA_VIDEO, DEMO_LOCAL_TRACK);
        }else {
            ret = m_pWMEDemo->StopMediaTrack(DEMO_MEDIA_VIDEO, DEMO_PREVIEW_TRACK);
        }
    }else {
        ret = m_pWMEDemo->StopMediaTrack(DEMO_MEDIA_VIDEO, DEMO_REMOTE_TRACK);
    }
    
    return ret;
}

- (long)clickedConnect
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    [self createAudioClient];
    [self createVideoClient];
    
    if (_isHost)
    {
        if (!_useICE) {
            m_pWMEDemo->InitHost(DEMO_MEDIA_AUDIO);
            m_pWMEDemo->InitHost(DEMO_MEDIA_VIDEO);
        }else {
            m_pWMEDemo->InitHost(DEMO_MEDIA_AUDIO, [_myName UTF8String],
                                  [_jingleServerIP UTF8String], [_jingleServerPort intValue],
                                  [_stunServerIP UTF8String], [_stunServerPort intValue]);
            m_pWMEDemo->InitHost(DEMO_MEDIA_VIDEO, [_myName UTF8String],
                                  [_jingleServerIP UTF8String], [_jingleServerPort intValue],
                                  [_stunServerIP UTF8String], [_stunServerPort intValue]);
        }
    }
    else
    {
        if (!_useICE) {
            m_pWMEDemo->ConnectRemote(DEMO_MEDIA_AUDIO, (char *)[_hostIPAddress UTF8String]);
            m_pWMEDemo->ConnectRemote(DEMO_MEDIA_VIDEO, (char *)[_hostIPAddress UTF8String]);
        }else {
            m_pWMEDemo->ConnectRemote(DEMO_MEDIA_AUDIO, [_myName UTF8String], [_hostName UTF8String],
                                       [_jingleServerIP UTF8String], [_jingleServerPort intValue],
                                       [_stunServerIP UTF8String], [_stunServerPort intValue]);
            m_pWMEDemo->ConnectRemote(DEMO_MEDIA_VIDEO, [_myName UTF8String], [_hostName UTF8String],
                                       [_jingleServerIP UTF8String], [_jingleServerPort intValue],
                                       [_stunServerIP UTF8String], [_stunServerPort intValue]);
        }
    }
    
    return WME_S_OK;
}

- (void)clickedDisconnect
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->DisConnect(DEMO_MEDIA_AUDIO);
    m_pWMEDemo->DisConnect(DEMO_MEDIA_VIDEO);
    [self deleteAudioClient];
    [self deleteVideoClient];
}

- (long)setVideoCameraDevice:(NSInteger)index
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    long ret = WME_E_FAIL;
    
    [self queryVideoCameraCapabilities];
    if (index < _videoInList.size()) {
        //_cameraIndex = index;
        _cameraPosition = _videoInList[index].position;
        DeviceProperty *dp = &(_videoInList.at(index));
        ret = m_pWMEDemo->SetCamera(_bVideoSending ? DEMO_LOCAL_TRACK : DEMO_PREVIEW_TRACK, dp->dev);
    }
    return ret;
}

- (void)switchCameraDevice
{
    self.cameraIndex = (_cameraIndex + 1) % _videoInList.size();
}

- (long)setVideoEncodingParam:(NSInteger)index
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    long ret = WME_E_FAIL;
    if(index < _videoCapList.size()) {
        //_videoCapIndex = index;
        WmeVideoMediaCapability *pVMC = &(_videoCapList.at(index));
        ret = m_pWMEDemo->SetMediaCapability(DEMO_MEDIA_VIDEO, _bVideoSending ? DEMO_LOCAL_TRACK:DEMO_PREVIEW_TRACK, pVMC);
    }
    return ret;
}

- (long)setVideoCameraParam:(NSInteger)index
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    long ret = WME_E_FAIL;
    if (index < _cameraCapList.size()) {
        //_cameraCapIndex = index;
        WmeDeviceCapability *pDC = &(_cameraCapList.at(index));
        DEMO_TRACK_TYPE ttype = DEMO_PREVIEW_TRACK;
        if (_bVideoSending) {
            ttype = DEMO_LOCAL_TRACK;
        }
        m_pWMEDemo->StopMediaTrack(DEMO_MEDIA_VIDEO, ttype);
        ret = m_pWMEDemo->SetCameraCapability(ttype, pDC);
        m_pWMEDemo->StartMediaTrack(DEMO_MEDIA_VIDEO, ttype);
        
    }
    return ret;
}

- (long)setVideoQualityType
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    long devcie_platform_type = [self detectPlatform];
    WmeVideoQualityType videoQualitytype;
    
    videoQualitytype = WmeVideoQuality_SD;
    if(devcie_platform_type <= tDeviceiPhone4GCDMA)
        videoQualitytype = WmeVideoQuality_SLD;
    
    return m_pWMEDemo->SetVideoQuality(DEMO_LOCAL_TRACK, videoQualitytype);
    
}

- (long)getVideoMediaCapability:(WmeVideoMediaCapability&)vMC
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    return m_pWMEDemo->GetCapability(DEMO_MEDIA_VIDEO, DEMO_LOCAL_TRACK, &vMC);
}

- (void)setAudioCaptureDevice:(NSInteger)index
{
    return_if_fail(m_pWMEDemo != NULL);
    
    if (index < _audioInList.size()) {
        //_micIndex = index;
        DeviceProperty *dp = &(_audioInList.at(index));
        m_pWMEDemo->SetMic(dp->dev);
    }
}

- (long)setAudioEncodingParam:(NSInteger)index
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    long ret = WME_E_FAIL;
    if (index < _audioCapList.size()) {
        //_audioCapIndex = index;
        WmeAudioMediaCapability *pAMC = &(_audioCapList.at(index));
        ret = m_pWMEDemo->SetMediaCapability(DEMO_MEDIA_AUDIO, DEMO_LOCAL_TRACK, pAMC);
    }
    return ret;
}

- (void)setAudioSpeaker:(NSInteger)index
{
    return_if_fail(m_pWMEDemo != NULL);
    
    if (index < _audioOutList.size()) {
        //_speakerIndex = index;
        _speakerPosition = _audioOutList[index].position;
        DeviceProperty *dp = &(_audioOutList.at(index));
        m_pWMEDemo->SetSpeaker(dp->dev);
    }
}

- (void)switchAudioSpeaker
{
    self.speakerIndex = (_speakerIndex + 1) % _audioOutList.size();
}

- (void)setRemoteRender:(void *)render
{
    _remoteRender = render;
    
    return_if_fail(m_pWMEDemo != NULL);
    
    if (render)
        m_pWMEDemo->SetRenderView(DEMO_REMOTE_TRACK, render);
    else
        m_pWMEDemo->StopRenderView(DEMO_REMOTE_TRACK);
}

- (void)setLocalRender:(void *)render
{
    _localRender = render;
    
    return_if_fail(m_pWMEDemo != NULL);
    
    DEMO_TRACK_TYPE ttype = _bVideoSending ? DEMO_LOCAL_TRACK:DEMO_PREVIEW_TRACK;
    if (render)
        m_pWMEDemo->SetRenderView(ttype, render);
    else
        m_pWMEDemo->StopRenderView(ttype);
}

- (long)setRenderAdaptiveAspectRatio:(BOOL)enable
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    return m_pWMEDemo->SetRenderAspectRatioSameWithSource(_bVideoSending ? DEMO_LOCAL_TRACK : DEMO_PREVIEW_TRACK, enable);
}

- (void)getVoiceLevel:(unsigned int &)level
{
    return_if_fail(m_pWMEDemo != NULL);
    
    m_pWMEDemo->GetVoiceLevel(level);
}

- (long)getVideoStatistics:(WmeSessionStatistics &)statistics
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    return m_pWMEDemo->GetVideoStatistics(statistics);
}

- (long)getAudioStatistics:(WmeSessionStatistics &)statistics
{
    returnv_if_fail(m_pWMEDemo != NULL, WME_E_FAIL);
    
    return m_pWMEDemo->GetAudioStatistics(statistics);
}

- (long)detectPlatform
{
	char tDevice[32] = "";
	size_t size = sizeof(tDevice);
	sysctlbyname("hw.machine", tDevice, &size, 0, 0);
    
	
	if(strcmp(tDevice, "i386") == 0 || strcmp(tDevice, "x86_64") == 0)
		return tDeviceSimulator;
    
    //iphone
    if(strncmp(tDevice, "iPhone", 6) == 0)
    {
        switch(tDevice[6] - '0')
        {
            case 2: return tDeviceiPhone3GS;
            case 3:
            {
                if(strcmp(tDevice, "iPhone3,3") == 0)
                    return tDeviceiPhone4GCDMA;
                return tDeviceiPhone4G;
            }
            case 4: return tDeviceiPhone4S;
            case 5: return tDeviceiPhone5;
            default: return tDeviceiPhoneFuture;
        }
    }
    
    //ipad
    if(strncmp(tDevice, "iPad", 4) == 0)
    {
        switch(tDevice[4] - '0')
        {
            case 1: return tDeviceiPad1G;
            case 2:
            {
                if(strcmp(tDevice, "iPad2,1") == 0)
                    return tDeviceiPad2GWiFi;
                else if(strcmp(tDevice, "iPad2,3") == 0 || strcmp(tDevice, "iPad2,4") == 0)
                    return tDeviceiPad2GCDMA;
                return tDeviceiPad2GGSM;
            }
            case 3:
            {
                if(strcmp(tDevice, "iPad3,1") == 0)
                    return tDeviceiPad3;
                else if(strcmp(tDevice, "iPad3,3") == 0)
                    return tDeviceiPad3CDMA;
                return tDeviceiPad3ATT;
            }
            default: return tDeviceiPadFuture;
        }
    }
    
    //ipod
    if(strncmp(tDevice, "iPod", 4) == 0)
    {
        switch(tDevice[4] - '0')
        {
            case 3: return tDeviceiPod3G;
            case 4: return tDeviceiPod4G;
            default: return tDeviceiPodFuture;
        }
    }
    
	return tDeviceNotSupport;
}

@end
