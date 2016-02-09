//
//  VisualizerView.h
//  iPodVisualizer
//
//  Created by Xinrong Guo on 13-3-30.
//  Copyright (c) 2013 Xinrong Guo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface VisualizerView : NSView

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
- (void)update:(double)scale;

@end
