//
//  AlertManager.m
//  Tomato
//
//  Created by Lin Teng on 1/10/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "AlertManager.h"
#import "SettingsManager.h"

@implementation AlertManager

//@synthesize soundFileObject, soundFileURLRef;

+ (AlertManager*)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static AlertManager* _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}


 -(id) init {
     if ((self = [super init])) {                 
         // Set up AVAudioPlayer
         // Set up the audio session
         // See handy chart on pg. 55 of the Audio Session Programming Guide for what the categories mean
         // Not absolutely required in this example, but good to get into the habit of doing
         // See pg. 11 of Audio Session Programming Guide for "Why a Default Session Usually Isn't What You Want"
         NSError *setCategoryError = nil;
         [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
     }
     return self; 
 }

- (void)playSampleSound
{
    [self playSoundFile:[SettingsManager sharedInstance].sampleSoundFile];
}

- (void)playPomodoroStart
{
    [self playSoundFile:[SettingsManager sharedInstance].pomodoroStartSoundFile];
    if ([SettingsManager sharedInstance].alarmVibration) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }    
}

- (void)playPomodoroWarning
{
    [self playSoundFile:[SettingsManager sharedInstance].pomodoroWarningSoundFile];
    if ([SettingsManager sharedInstance].alarmVibration) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)playPomodoroEnd
{
    [self playSoundFile:[SettingsManager sharedInstance].pomodoroEndSoundFile];
    if ([SettingsManager sharedInstance].alarmVibration) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)playBreakWarning
{
    [self playSoundFile:[SettingsManager sharedInstance].breakWarningSoundFile];
    if ([SettingsManager sharedInstance].alarmVibration) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)playBreakEnd
{
    [self playSoundFile:[SettingsManager sharedInstance].breakEndSoundFile];
    if ([SettingsManager sharedInstance].alarmVibration) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

//
//- (void)playTicking
//{
//    [self playTickingForDuration:-1];
//}

- (void)playTickingForDuration:(NSTimeInterval)duration;
{
    [self playTickingForDuration:duration afterDelay:0];
}

- (void)playTickingForDuration:(NSTimeInterval)duration afterDelay:(NSTimeInterval)delayTime
{
    [_tickingPlayer stop];
    
    if ([[SettingsManager sharedInstance].tickingSoundFile isEqualToString:@"empty_sound"] ||
        [SettingsManager sharedInstance].tickingSoundFile.length == 0) {
        return;
    }
    
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:[SettingsManager sharedInstance].tickingSoundFile
                                              withExtension:@"caf"];
    NSError *error;
    _tickingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    [_tickingPlayer setDelegate:self];
    // Check to see if iPod music is already playing
	//UInt32 propertySize = sizeof(_otherMusicIsPlaying);
	//AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &_otherMusicIsPlaying);
	
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [_tickingPlayer prepareToPlay];
    [_tickingPlayer setVolume:1.0];
    
    NSInteger loops = 1;
    if (duration == -1) {
        loops = -1;
    }
    else if (_tickingPlayer.duration <= 0)
    {
        loops = 0;
    }
    else {
        loops = fabs(duration)/_tickingPlayer.duration;
    }
    [_tickingPlayer setNumberOfLoops:loops];
    
    if (delayTime > 0 ) {
        [_tickingPlayer playAtTime:_tickingPlayer.deviceCurrentTime + delayTime];
    }
    else {
        [_tickingPlayer play];
    }      
    
    /*
     // Play the music if no other music is playing and we aren't playing already
     if (_otherMusicIsPlaying != 1 ) {
     [_avMusicPlayer prepareToPlay];
     [_avMusicPlayer setVolume:[SettingsManager sharedInstance].soundVolume];
     [_avMusicPlayer play];
     if (repeat) {
     [_avMusicPlayer setNumberOfLoops:-1];
     }
     }
     else {
     #warning check avMusicPlay can do this thing?
     // Play the music by AudioServicesPlayAlertSound
     AudioServicesPlayAlertSound (soundFileObject);
     //AudioServicesPlaySystemSound(_pewPewSound);
     }
     */
}

- (void)adjustTickingVolume:(NSNumber*)volume
{
    [_tickingPlayer setVolume:volume.floatValue];
}

- (void)adjustTickingVolume:(NSNumber*)volume afterDelay:(NSTimeInterval)delayTime
{
    [self performSelector:@selector(adjustTickingVolume:) withObject:volume afterDelay:delayTime];
}

- (void)stopTicking
{
    [_tickingPlayer stop];
}

- (void)triggerVibration
{
    if ([SettingsManager sharedInstance].alarmVibration) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

// play any sound if needed, for example, when user play the sounds in the settings
- (void)playSoundFile:(NSString*)fileName
{
#warning performance measure, is the latence is ok or not?
    //CFURLRef		soundFileURLRef;
	//SystemSoundID	soundFileObject;    
    if ([fileName isEqualToString:@"empty_sound"] || fileName.length == 0) {
        return;
    }    
    NSURL *soundURL   = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"caf"];        
    NSError *error;
    _avMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    [_avMusicPlayer setDelegate:self];  // We need this so we can restart after interruptions
    [_avMusicPlayer prepareToPlay];
    //[_avMusicPlayer setVolume:[SettingsManager sharedInstance].soundVolume];
    [_avMusicPlayer play];        
    return;
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
    /*
     _backgroundMusicInterrupted = YES;
     _backgroundMusicPlaying = NO;
     */
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player {
    /*
     if (_backgroundMusicInterrupted) {
     [self tryPlayMusic];
     _backgroundMusicInterrupted = NO;
     }
     */
}

#pragma mark - old code

/*
-(void) trigger {
    [self triggerSound];
    [self triggerDialog];
}

-(void) triggerSound {
    // Check to see if iPod music is already playing
	UInt32 propertySize = sizeof(_otherMusicIsPlaying);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &_otherMusicIsPlaying);
	
	// Play the music if no other music is playing and we aren't playing already
	if (_otherMusicIsPlaying != 1 ) {
		[_backgroundMusicPlayer prepareToPlay];
        [_backgroundMusicPlayer setVolume: 0.05];
		[_backgroundMusicPlayer play];
	}
    else {
        // Play the music by AudioServicesPlayAlertSound
        AudioServicesPlayAlertSound (soundFileObject);
        //AudioServicesPlaySystemSound(_pewPewSound);
    }
    return;
}

-(void) triggerDialog {
    if (![alertDialog isVisible]) {
        [alertDialog show];
    }
}


*/

@end
