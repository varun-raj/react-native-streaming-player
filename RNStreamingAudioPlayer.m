//React Native Audio Player logic(no UI)
#import "RNStreamingAudioPlayer.h"
#import <React/RCTBridge.h>
#import <React/RCTConvert.h>

@implementation RNStreamingAudioPlayer

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initPlayer:(NSString *)url songInfo:(NSDictionary *)songInfo){
  if(!([url length]>0)) return;
  
  NSString *name = [RCTConvert NSString:songInfo[@"name"]];
  NSString *artist_name = [RCTConvert NSString:songInfo[@"artist_name"]];
//  NSString *artwork = [RCTConvert NSString:songInfo[@"artwork"]];

  NSURL *soundUrl = [[NSURL alloc] initWithString:url];
  self.audioItem = [AVPlayerItem playerItemWithURL:soundUrl];
  self.audioPlayer = [AVPlayer playerWithPlayerItem:self.audioItem];
  
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
  [[AVAudioSession sharedInstance] setActive:YES error:nil];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  
//  NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: artwork]];
//  UIImage *artworkImage = [UIImage imageWithData: imageData];
  
//  MPMediaItemArtwork *playerArtwork = [[MPMediaItemArtwork alloc]initWithImage:artworkImage];

  [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{
                                                            MPMediaItemPropertyTitle : name,
                                                            MPMediaItemPropertyArtist : artist_name,
                                                            MPNowPlayingInfoPropertyPlaybackRate : @1.0f
                                                            };
  
  MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

  commandCenter.previousTrackCommand.enabled = NO;
  [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTapped:)];
  
  commandCenter.likeCommand.enabled = YES;
  commandCenter.likeCommand.active = YES;
  
  commandCenter.playCommand.enabled = YES;
  [commandCenter.playCommand addTarget:self action:@selector(playAudio)];
  
  commandCenter.pauseCommand.enabled = YES;
  [commandCenter.pauseCommand addTarget:self action:@selector(pauseAudio)];
  
  commandCenter.nextTrackCommand.enabled = NO;
  [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTapped:)];
  
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.audioItem];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self selector:@selector(playerItemStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.audioItem];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification{
  NSLog(@"Called");
  [self.audioItem seekToTime:kCMTimeZero];
  [self sendEventWithName:@"AudioEnded" body:@{@"event": @"finished"}];
  
}
- (void)playerItemStalled:(NSNotification *)notification{
  [self.audioPlayer play];
}

-(void)playAudio{
  [self.audioPlayer play];
}

-(void)pauseAudio{
  [self.audioPlayer pause];
}

-(void)nextTapped:(MPRemoteCommandEvent *)event{
  [self sendEventWithName:@"goToNext" body:@{@"event": @"nextSong"}];
}

-(void)previousTapped:(MPRemoteCommandEvent *)event{
  [self sendEventWithName:@"goToPrevious" body:@{@"event": @"previousSong"}];
}

RCT_EXPORT_METHOD(getDuration:(RCTResponseSenderBlock)callback){
  while(self.audioItem.status != AVPlayerItemStatusReadyToPlay){
  }  //this is kind of crude but it will prevent the app from crashing due to a "NAN" return(this allows the getDuration method to be executed in the componentDidMount function of the React class without the app crashing
  float duration = CMTimeGetSeconds(self.audioItem.duration);
  callback(@[[[NSNumber alloc] initWithFloat:duration]]);
}


RCT_EXPORT_METHOD(getCurrentTime:(RCTResponseSenderBlock)callback){
  while(self.audioItem.status != AVPlayerItemStatusReadyToPlay){
  }  //this is kind of crude but it will prevent the app from crashing due to a "NAN" return(this allows the getDuration method to be executed in the componentDidMount function of the React class without the app crashing
  float duration = CMTimeGetSeconds(self.audioItem.currentTime);
  callback(@[[[NSNumber alloc] initWithFloat:duration]]);
}

- (NSArray<NSString *> *)supportedEvents
{
  NSArray *events = @[@"AudioEnded", @"goToPrevious", @"goToNext"];
  return events;
}

RCT_EXPORT_METHOD(play){
  [self.audioPlayer play];
}

RCT_EXPORT_METHOD(pause){
  [self.audioPlayer pause];
}

RCT_EXPORT_METHOD(setVolume:(nonnull NSNumber *)volumeValue){
    self.audioPlayer.volume = [volumeValue floatValue];
}

RCT_EXPORT_METHOD(seekToTime:(nonnull NSNumber *)toTime){
  [self.audioPlayer seekToTime: CMTimeMakeWithSeconds([toTime floatValue], NSEC_PER_SEC)];
}

@end
