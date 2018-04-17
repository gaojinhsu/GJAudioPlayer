//
//  GJStreamingAudioPlayer.h
//  OpenALDemo
//
//  Created by Gaojin Hsu on 7/5/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GJStreamingAudioPlayer : NSObject

//set up audio resources
- (BOOL)initOpenAL;

//clean audio resources
- (void)cleanUpOpenAL;

//receive PCM audio data to play
- (void)receiveAudioStreamData:(const unsigned char*)data length:(unsigned)length;

@end
