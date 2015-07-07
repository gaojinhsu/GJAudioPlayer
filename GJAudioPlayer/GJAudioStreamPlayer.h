//
//  GJStreamingAudioPlayer.h
//  OpenALDemo
//
//  Created by Gaojin Hsu on 7/5/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GJStreamingAudioPlayer : NSObject

- (void)receiveAudioStreamData:(const unsigned char*)data length:(unsigned)length;

@end
