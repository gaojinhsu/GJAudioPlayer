//
//  GJFileAudioPlayer.m
//  OpenALDemo
//
//  Created by Gaojin Hsu on 7/4/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import "GJFileAudioPlayer.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation GJFileAudioPlayer
{
    ALCcontext *_context;
    ALCdevice *_device;
    ALuint _sourceID;
    ALuint _bufferID;
    NSTimer *_timer;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initOpenAL];
    }
    return self;
}

- (BOOL)isPlaying
{
    ALint state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    return state == AL_PLAYING;
}

- (void)play
{
    ALint state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    
    if (state != AL_PLAYING) {
        alSourcePlay(_sourceID);
    }
}

- (void)stop
{
    ALint state;
    alGetSourcei(_sourceID, AL_SOURCE_STATE, &state);
    
    if (state != AL_STOPPED) {
        alSourceStop(_sourceID);
    }
}


- (BOOL)initOpenAL
{
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
    
    return YES;
}




#pragma mark -
#pragma mark Play Audio File Methods

- (void)playAudioFile:(NSString*)filePath loopMode:(BOOL)isLoop
{
    if (!filePath)
    {
        NSLog(@"openAL: filePath is nil");
        return;
    }
    
    // open the audio file
    AudioFileID fileID = [self openAudioFile:filePath];
    
    // get size of the audio file
    UInt32 fileSize = [self audioFileSize:fileID];
    
    // create a place to let audio data stay temporarily
    unsigned char *outData = malloc(fileSize);
    
    OSStatus result = noErr;
    
    // read the audio file to outData
    result = AudioFileReadBytes(fileID, false, 0, &fileSize, outData);
    
    // close the audio file
    AudioFileClose(fileID);
    
    if (result != 0) {
        NSLog(@"openAL: cannot load effect: %@", filePath);
    }
    
    // genarate a openAL buffer
    alGenBuffers(1, &_bufferID);
    
    //  put data into the openAL buffer
    alBufferData(_bufferID, AL_FORMAT_STEREO16, outData, fileSize, 8000);
    
    // free outData
    if (outData) {
        free(outData);
        outData = NULL;
    }
    
    // genarate a openAL source
    alGenSources(1, &_sourceID);
    
    // attach the buffer to the source
    alSourcei(_sourceID, AL_BUFFER, _bufferID);
    
    // set some basic source params
    alSourcei(_sourceID, AL_PITCH, 1.0f);
    alSourcei(_sourceID, AL_GAIN, 1.0f);
    alSourcei(_sourceID, AL_LOOPING, isLoop ? AL_TRUE : AL_FALSE);
    alSourcef(_sourceID, AL_SOURCE_TYPE, AL_STATIC);
    
    // play audio
    [self play];

}

- (AudioFileID)openAudioFile:(NSString*)filePath
{
    AudioFileID outFileID;
    
    NSURL *aUrl = [NSURL fileURLWithPath:filePath];
    
#if TARGET_OS_IPHONE
    OSStatus result = AudioFileOpenURL((__bridge CFURLRef)aUrl, kAudioFileReadPermission, 0, &outFileID);
#else
    OSStatus result = AudioFileOpenURL((__bridge CFURLRef)afUrl, fsRdPerm, 0, &outAFID);
#endif
    if (result != 0) NSLog(@"openAL: cannot open file: %@", filePath);
    return outFileID;

}

- (UInt32)audioFileSize:(AudioFileID)audioFileID
{
    UInt64 outDataSize = 0;
    UInt32 thePropSize = sizeof(UInt64);
    OSStatus result = AudioFileGetProperty(audioFileID, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
    if(result != 0)
    {
        NSLog(@"openAL: cannot find file size");
 
    }
    return (UInt32)outDataSize;
}

#pragma mark -
#pragma mark Clean Resources

- (void)cleanUpOpenAL
{
    // delete the source
    alDeleteSources(1, &_sourceID);
    
    // delete buffer
    alDeleteBuffers(1, &_bufferID);
    
    // destory the context
    alcDestroyContext(_context);
    _context = NULL;
    
    // close the device
    alcCloseDevice(_device);
    _device = NULL;
}

- (void)dealloc
{
    [self cleanUpOpenAL];
}

@end
