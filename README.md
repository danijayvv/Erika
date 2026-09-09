# 🌼 Erika 
Music deserves to be seen.<br/>
Erika makes audio visualization quick and simple.<br/>
> Developed by Dani (danijayvv) @ [DXNVXV](https://dxnvxv.studio). <br/>
<br/>

Stop overcomplicating sounds, let's keep it simple:
```
Erika.new():Play( SOUND_ID_HERE )
```
Better yet, let's add a visualizer too:
```
-- Code soon to come.
```
Or... let's have instances groove to the beat:
```
Erika.new():Play( SOUND_ID_HERE ).OnBeat:Connect(function( Scale: number )
	UIScale.Scale = 1 + Scale * 0.5
end)
```
You can have it all!

## Features
- One-line setup from `SoundId` to a playing, analyzable sound
- Built-in beat detection with `Tangela.OnBeat`, driven by Roblox's `AudioAnalyzer`
- Fully optional configuration with sensible defaults for everything
- Support for your own `AudioPlayer` & `AudioAnalyzer` instances
- Lightweight API that's simple to understand

## Setup
1. Insert the Erika library into any client-accessible service (e.g. `ReplicatedStorage`, `StarterPlayerScripts`)
2. Require Erika: ```local Erika = require(<path to Erika>)```
3. Read the API below to get started

## API
### `Erika.new` & `Tangela:Set`
```
local Tangela = Erika.new( 'Tangela' , {
	AudioPlayer = AUDIO_PLAYER_HERE,
	AudioAnalyzer = AUDIO_ANALYZER_HERE,
	WindowSize = Enum.AudioWindowSize.Large,
} )

Tangela:Set{
	SoundId = SOUND_ID_HERE,
	Looping = true,
	PlaybackSpeed = 1.0,
}
```
> [!NOTE]
> `Erika` is the class. `Tangela` is the object created by `Erika.new()`.

`Erika.new` accepts optional constructor parameters that must be provided when creating the object. These parameters cannot be added after creation. `Tangela:Set` handles properties that can be configured or changed after the object has been created.

### `Tangela:Play`
```
Tangela:Play{ SoundId = SOUND_ID_HERE , Looping = true , PlaybackSpeed = 1.0 }
Tangela:Play( SOUND_ID_HERE )
```
Plays the sound, swapping in a new `SoundId`, `Looping`, or `PlaybackSpeed` if provided.
> [!NOTE]
> `Tangela:Play` accepts either a `table` of options (for setting multiple properties at once) or just a `SoundId` directly.

### `Tangela:Stop`
```
Tangela:Stop()
```
Stops the sound.

### `Tangela.OnBeat`
```
Tangela.OnBeat:Connect(function( Scale: number )
	
end)
```
Fires every frame with a `Scale` value between `0` and `1`, derived from the spectrum data given by the `AudioAnalyzer`.
