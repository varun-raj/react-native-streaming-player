//React Native Audio Player logic(no UI)

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@import AVFoundation;

@interface RNStreamingAudioPlayer : RCTEventEmitter <RCTBridgeModule>

@property (strong, nonatomic) AVPlayerItem *audioItem;
@property (strong, nonatomic) AVPlayer *audioPlayer;
@end
