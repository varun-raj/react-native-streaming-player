//React Native Audio Player logic(no UI)

#import "RNStreamingAudioPlayer.h"
#import <React/RCTBridge.h>

@implementation RNStreamingAudioPlayer

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initWithURL:(NSString *)url){
  if(!([url length]>0)) return;
    
  NSURL *soundUrl = [[NSURL alloc] initWithString:url];
  
  self.audioItem = [AVPlayerItem playerItemWithURL:soundUrl];
  
  self.audioPlayer = [AVPlayer playerWithPlayerItem:self.audioItem];
  
  [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.audioItem];
  
  [[NSNotificationCenter defaultCenter]
    addObserver:self selector:@selector(playerItemStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.audioItem];
  
}


- (void)playerItemDidReachEnd:(NSNotification *)notification{
  [self.audioItem seekToTime:kCMTimeZero];
  [self sendEventWithName:@"AudioEnded" body:@{@"event": @"finished"}];
}
- (void)playerItemStalled:(NSNotification *)notification{
  [self.audioPlayer play];
}



RCT_EXPORT_METHOD(getDuration:(RCTResponseSenderBlock)callback){
  while(self.audioItem.status != AVPlayerItemStatusReadyToPlay){
  }  //this is kind of crude but it will prevent the app from crashing due to a "NAN" return(this allows the getDuration method to be executed in the componentDidMount function of the React class without the app crashing
  float duration = CMTimeGetSeconds(self.audioItem.duration);
  callback(@[[[NSNumber alloc] initWithFloat:duration]]);
}


- (NSArray<NSString *> *)supportedEvents
{
  NSArray *events = @[@"AudioEnded"];
  return events;
}


RCT_EXPORT_METHOD(play){
  [self.audioPlayer play];
}

RCT_EXPORT_METHOD(pause){
  [self.audioPlayer pause];

}

RCT_EXPORT_METHOD(seekToTime:(nonnull NSNumber *)toTime){
  [self.audioPlayer seekToTime: CMTimeMakeWithSeconds([toTime floatValue], NSEC_PER_SEC)];
}

RCT_EXPORT_METHOD(setVolume:(nonnull NSNumber *)volumeValue){
  self.audioPlayer.volume = [volumeValue floatValue];
}

@end
