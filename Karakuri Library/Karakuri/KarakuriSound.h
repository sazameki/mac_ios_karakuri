//
//  KarakuriSound.h
//  Karakuri Prototype
//
//  Created by numata on 09/07/24.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Karakuri/KarakuriLibrary.h>

#if KR_IPHONE && !KR_IPHONE_MACOSX_EMU
#import <AVFoundation/AVFoundation.h>
#endif

#import <AudioToolbox/AudioToolbox.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>


void _KRInitOpenAL();
void _KRCleanUpOpenAL();


@interface _KarakuriSound : NSObject {
    float   *mAudioBuffer;
    
    ALsizei mDataSize;
    ALuint  mALBuffer;
    ALuint  mALSource;
    ALsizei mSampleRate;
    ALenum  mOutputFormat;
    
    ALfloat mSourcePos[3];
    
    float   mVolume;
    float   mPitch;
}

+ (float)listenerHorizontalOrientation;
+ (void)setListenerHorizontalOrientation:(float)radAngle;

+ (void)getListenerX:(float *)x y:(float *)y z:(float *)z;
+ (void)setListenerX:(float)x y:(float)y z:(float)z;

- (id)initWithName:(NSString *)name doLoop:(BOOL)doLoop;

- (void)play;
- (void)pause;
- (void)stop;

- (BOOL)isPlaying;
- (BOOL)isPaused;

- (void)getSourceX:(float *)x y:(float *)y z:(float *)z;
- (void)setSourceX:(float)x y:(float)y z:(float)z;

- (float)pitch;
- (void)setPitch:(float)pitch;

- (float)volume;
- (void)setVolume:(float)volume;

@end

