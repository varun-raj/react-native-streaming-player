# react-native-streaming-player

IOS class to add react-native implementation for web audio urls(look at AVPlayer documentation for audio compatibility). Tested using mp3 urls.

## Add it to your project
<ol>
	<li>Run '<a href="https://www.npmjs.com/package/react-native-streaming-player">npm install react-native-streaming-player --save</a>'</li>
	<li>Add .h and .m files to "your_project_name" folder in XCode and restart application</li>
	<li>var audio = require('react-native').NativeModules.RNStreamingAudioPlayer;</li>
</ol>

## Basic usage

```javascript
//To initialize the audio clip with meta data

var songInfo = {
	name: "Name of the song",
  artist_name: "Song's band name",
  artwork: "Song's cover image",
};

audio.initPlayer("http://your_audio_url_here", songInfo);

//To retrieve the length of the clip in seconds as a float
audio.getDuration((duration) => {
	//do what you need with duration variable
	//***Example
	var minutes = Math.floor(duration/60);
	var seconds = Math.ceil((duration/60 - minutes) * 60);
	this.setState({minutes: minutes, seconds: seconds, totalSeconds: duration});
});

//To play audio clip
audio.play();

//To pause audio clip
audio.pause();

//To set volume of the player
audio.setVolume(0.3);

//To seek to a specific time in seconds
audio.seekToTime(time_in_seconds);
```

## New Additions
<ol>
<li>Audio will automatically set time to zero once it has reached the end</li>
<li>New Function to seek to a certain time in the audio clip</li>
</ol>


```javascript
// Import 
var { NativeEventEmitter } = require('react-native');
const audioEvent = new NativeEventEmitter(NativeModules.RNStreamingAudioPlayer);

//Listen for audio end
var subscription = NativeAppEventEmitter.addListener(
	'AudioEnded',
	(trigger) => {console.log(trigger.event)};
);

//Listen for previous song action from Media center
var subscription = NativeAppEventEmitter.addListener(
	'goToPrevious',
	(trigger) => {console.log(trigger.event)};
);

//Listen for next song action from Media center
var subscription = NativeAppEventEmitter.addListener(
	'goToNext',
	(trigger) => {console.log(trigger.event)};
);
```
