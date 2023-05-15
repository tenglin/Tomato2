//
//  AlertManager.h
//  Tomato
//
//  Created by Lin Teng on 1/10/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AlertManager : NSObject <AVAudioPlayerDelegate>
{
@private
    //UInt32 _otherMusicIsPlaying;
    AVAudioPlayer *_avMusicPlayer;
    //AVAudioPlayer *_tickingPlayer;
    //BOOL _backgroundMusicPlaying;
	//BOOL _backgroundMusicInterrupted;
}
//@property (readwrite)	CFURLRef		soundFileURLRef;
//@property (readonly)	SystemSoundID	soundFileObject;

+ (AlertManager*)sharedInstance;
 
@property (strong, nonatomic) AVAudioPlayer *tickingPlayer;

- (void)playSampleSound;
- (void)playPomodoroStart;
- (void)playPomodoroWarning;
- (void)playPomodoroEnd;
- (void)playBreakWarning;
- (void)playBreakEnd;
//- (void)playTicking;
- (void)playTickingForDuration:(NSTimeInterval)duration;
- (void)playTickingForDuration:(NSTimeInterval)duration afterDelay:(NSTimeInterval)delayTime;
- (void)adjustTickingVolume:(NSNumber*)volume; // volume from 0.0 to 1.0
- (void)adjustTickingVolume:(NSNumber*)volume afterDelay:(NSTimeInterval)delayTime;
- (void)stopTicking;

- (void)triggerVibration;

// play any sound if needed, for example, when user play the sounds in the settings
- (void)playSoundFile:(NSString*)fileName;

@end
