//
//  GJStreamingAudioPlayer.m
//  OpenALDemo
//
//  Created by Gaojin Hsu on 7/5/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import "GJAudioStreamPlayer.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@implementation GJStreamingAudioPlayer {
    ALCcontext *_context;
    ALCdevice *_device;
    ALuint _sourceID;
    NSTimer *_timer;
}

- (BOOL)initOpenAL {
    if (!_device) {
        // open the device
        _device = alcOpenDevice(NULL);
    }
    
    if (!_device) {
        
        NSLog(@"openAL: open device failed");
        return NO;
    }
    
    if (!_context) {
        
        // create context within the device
        _context = alcCreateContext(_device, NULL);
        
        // set the context created above to the currently active one
        alcMakeContextCurrent(_context);
    }
    
    if (!_context) {
        NSLog(@"openAL: create context failed");
        return NO;
    }
    // genarate openAL source
    alGenSources(1, &_sourceID);
    
    // disable loop mode
    alSourcei(_sourceID, AL_LOOPING, AL_FALSE);
    
    // enable stream mode
    alSourcef(_sourceID, AL_SOURCE_TYPE, AL_STREAMING);
    
    // set volume
    alSourcef(_sourceID, AL_GAIN, 1);
    
    // clean error Info
    alGetError();
    
    // set a timer to clean processed buffers
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(cleanBuffers) userInfo:0 repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    
    return YES;
}

#pragma mark -
#pragma mark Play Audio Stream Methods

- (void)receiveAudioStreamData:(const unsigned char*)data length:(unsigned)length {
        ALenum error;
        
        error = alGetError();
        
        if (error != AL_NO_ERROR) {
            NSLog(@"openAL: error Info: %d", error);
            return;
        }
        
        if (data == NULL) {
            NSLog(@"openAL: audio stream data is NULL");
            return;
        }
        
        // genarate a buff to hold audio stream data
        ALuint bufferID = 0;
        alGenBuffers(1, &bufferID);
        
        error = alGetError();
        if (error != AL_NO_ERROR) {
            NSLog(@"openAL: genarate buffer failed, error code: %d", error);
        }
        
        // put audio stream data into the buffer
        alBufferData(bufferID, AL_FORMAT_MONO16, data, length, 16000);
        error = alGetError();
        if (error != AL_NO_ERROR) {
            NSLog(@"openAL: insert data into buffer failed, error code: %d", error);
        }
        
        // put the buffer into a queue
        alSourceQueueBuffers(_sourceID, 1, &bufferID);
        
        error = alGetError();
        if (error != AL_NO_ERROR) {
            NSLog(@"openAL: insert buffer into queque failed, error code: %d", error);
            return;
        }
        
        // play streaming audio
        [self play];
}

- (void)play {
    ALint state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    
    if (state != AL_PLAYING) {
        alSourcePlay(_sourceID);
    }
}

- (void)stop {
    ALint state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    
    if (state != AL_STOPPED) {
        alSourceStop(_sourceID);
    }
}


- (void)cleanBuffers {
    
#ifdef DEBUG
    NSLog(@"openAL: before clean up");
    [self getInfo];
#else
    
#endif
    
    ALint processed;
    alGetSourcei(_sourceID, AL_BUFFERS_PROCESSED, &processed);
    
    while (processed--) {
        ALuint bufferID;
        alSourceUnqueueBuffers(_sourceID, 1, &bufferID);
        alDeleteBuffers(1, &bufferID);
    }
    
    
#ifdef DEBUG
    NSLog(@"openAL: after clean up");
    [self getInfo];
#else
    
#endif
    
}

- (void)getInfo {
    ALint queued;
    ALint processed;
    alGetSourcei(_sourceID, AL_BUFFERS_PROCESSED, &processed);
    alGetSourcei(_sourceID, AL_BUFFERS_QUEUED, &queued);
    NSLog(@"openAL: process = %d, queued = %d", processed, queued);
    
}

#pragma mark -
#pragma mark Clean Resources

- (void)cleanUpOpenAL {
    // delete the source
    alDeleteSources(1, &_sourceID);
    
    // destory the context
    alcDestroyContext(_context);
    _context = NULL;
    
    // close the device
    alcCloseDevice(_device);
    _device = NULL;
    
    // delete timer
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [self cleanBuffers];
}

- (void)dealloc {
    [self cleanUpOpenAL];
}


@end
