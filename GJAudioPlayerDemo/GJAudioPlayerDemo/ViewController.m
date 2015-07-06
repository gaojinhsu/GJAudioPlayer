//
//  ViewController.m
//  GJAudioPlayerDemo
//
//  Created by Gaojin Hsu on 7/6/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import "ViewController.h"
#import "GJFileAudioPlayer.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) GJFileAudioPlayer *audioFilePlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _audioFilePlayer = [[GJFileAudioPlayer alloc]init];
    [_audioFilePlayer playAudioFile:[[NSBundle mainBundle]pathForResource:@"outSound" ofType:@"caf"] loopMode:YES];
}

- (IBAction)playButtonClicked:(id)sender {
    if (_audioFilePlayer.isPlaying) {
        [_audioFilePlayer stop];
        [_playButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else{
        [_audioFilePlayer play];
        [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
