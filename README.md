# <img src="https://dxnvxv.studio/assets/images/image05.jpg?v=1ba4ae39" alt="🌼" width="25">  Erika
Turn sound into something you can see. <br> Erika makes audio visualization quick and simple. <br> <br>
<img src="https://dxnvxv.studio/assets/images/image04.jpg?v=1ba4ae39" alt="A bed of flowers" width="500">

## Philosophy
Stop overcomplicating sounds, let's keep it simple:
```
Erika.new():Play( SOUND_ID_HERE )
```
Better yet, let's add a visualizer too:
```
-- Code soon to come.
```
And, let's have instances groove to the beat:
```
Erika.new():Play( SOUND_ID_HERE ).OnBeat:Connect(function( Scale: number )
	UIScale.Scale = 1 + Scale * 0.5
end)
```
> [!TIP]
> Methods are chainable, you can have it all!

## Features
- One-line setup from `SoundId` to a playing, analyzable sound
- Built-in beat detection with `Tangela.OnBeat`, driven by Roblox's `AudioAnalyzer`
- Fully optional configuration with sensible defaults for everything
- Support for your own `AudioPlayer` & `AudioAnalyzer` instances

## Setup
1. Insert the Erika library into any client-accessible service (e.g. `ReplicatedStorage`, `StarterPlayerScripts`)
2. Require Erika:
	- ```local Erika = require(<path to Erika>)```
3. Read the API below to get started

## API
### `Erika.new` & `Tangela:Set`
```
local Tangela = Erika.new( string , {
	AudioPlayer = AUDIO_PLAYER_HERE,
	AudioAnalyzer = AUDIO_ANALYZER_HERE,
	WindowSize = Enum.AudioWindowSize[SIZE_HERE],
} )

Tangela:Set{
	SoundId = SOUND_ID_HERE,
	Looping = boolean,
	PlaybackSpeed = number,
}
```
> [!NOTE]
> `Erika` is the class. `Tangela` is the object created by `Erika.new`.

`Erika.new` accepts optional constructor parameters that must be provided when creating the object. These parameters cannot be added after creation. `Tangela:Set` handles properties that can be configured or changed after the object has been created.

### `Tangela:Destroy`
```
Tangela:Destroy()
```
Stops beat detection, destroys every visualizer, and destroys the ```AudioAnalyzer``` and ```AudioPlayer``` instances.

<hr>

### `Tangela:Play`
```
Tangela:Play{ SoundId = SOUND_ID_HERE , Looping = boolean , PlaybackSpeed = number }
Tangela:Play( SOUND_ID_HERE )
```
Plays the sound, overriding `SoundId`, `Looping`, or `PlaybackSpeed` if provided.
> [!NOTE]
> `Tangela:Play` accepts either a `table` of options (same syntax as `Tangela:Set`) or just a `SoundId` directly.

### `Tangela:Stop`
```
Tangela:Stop( boolean? )
```
Stops the sound. If the passed ```boolean``` is true, the sound will have its ```TimePosition``` reset to 0.

<hr>

### `Tangela.Visualizers`
```
for __ , Visualizer in Tangela.Visualizers do
	print( Visualizer )
end
```
Holds every visualizer created via `Tangela:CreateVisualizer2D` or `Tangela:CreateVisualizer3D`.

### `Tangela:CreateVisualizer2D`
```
Tangela:CreateVisualizer2D( GuiObject , {
	BarCount = number,
	BarGap = number,
	BarDecay = number,
	BarMaxHeight = number,
	BarColorLow = Color3,
	BarColorHigh = Color3,
	MinHz = number,
	MaxHz = number,
} , ContainerAlignment , BarAlignment )
```
Creates a 2D bar visualizer parented to a ```GuiObject```. All fields in the ```table``` are optional and fall back to sensible defaults. <br>
`ContainerAlignment` and `BarAlignment` each accept `Top`, `Bottom`, or `Center`.

- `BarCount`: The number of bar frames created
- `BarGap`: The distance between every bar frame
- `BarDecay`: How long a bar frame holds its position before falling
- `BarMaxHeight`: The max scale a bar frame can reach
- `BarColorLow`: The color a bar frame is at its lowest
- `BarColorHigh`: The color a bar frame is at its highest
- `MinHz`: Locks the minimum accepted Hz
- `MaxHz`: Locks the maximum accepted Hz

### `Tangela:CreateVisualizer3D`

### `Tangela:ClearVisualizers`
```
Tangela:ClearVisualizers()
```
Destroys every visualizer created via `Tangela:CreateVisualizer2D` or `Tangela:CreateVisualizer3D` and empties `Erika.Visualizers`.

<hr>

### `Tangela.OnBeat`
```
Tangela.OnBeat:Connect(function( Scale: number )
	print( Scale )
end)
```
Fires every frame with a `Scale` value between `0` and `1`, derived from the spectrum data given by the `AudioAnalyzer`.

### `Tangela:SetBeatPreset`
```
Tangela:SetBeatPreset( 'Default' )
```
Remaps the range of values fired by ```Tangela.OnBeat```. Built-in presets are:
- `Default`: input `0.1`-`1.0` → output `0.0`-`1.0`
- `Punchy`: input `0.3`–`0.8` → output `0.8`–`1.0` (only strong hits register, and they hit hard)
- `Subtle`: input `0.2`–`0.9` → output `0.7`–`0.85` (a gentle pulse that never fully rests)
- `Smooth`: input `0.0`–`1.0` → output `0.1`–`0.6` (flattens peaks for continuous, non-jarring motion)
- `Gate_Lw`: binary on/off, switches to `1` once the beat crosses `50%` intensity
- `Gate_Av`: binary on/off, switches to `1` once the beat crosses `70%` intensity
- `Gate_Hi`: binary on/off, switches to `1` once the beat crosses `90%` intensity

## Credits
- **Erika** by [Dani (danijayvv)](https://github.com/danijayvv)
- **Art** by my lovely girlfriend, Anne

Support us @ [DXNVXV.COM](https://dxnvxv.studio)
