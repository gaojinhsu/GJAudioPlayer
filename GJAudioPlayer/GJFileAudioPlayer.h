//
//  GJFileAudioPlayer.h
//  OpenALDemo
//
//  Created by Gaojin Hsu on 7/4/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GJFileAudioPlayer : NSObject

- (id)init;

- (void)playAudioFile:(NSString*)filePath loopMode:(BOOL)isLoop;

- (void)play;

- (void)stop;

@property (nonatomic, assign, readonly) BOOL isPlaying;

@end
