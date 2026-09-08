-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local AnalyzerRegistry = {} :: AnalyzerRegistryClass & AnalyzerRegistryType
AnalyzerRegistry.__index = AnalyzerRegistry

-- // Services & Requires

-- // Variables & Constants
const rbxassetid = 'rbxassetid://'

-- // Tables & Types
export type AnalyzerRegistryClass = {
	__index: AnalyzerRegistryClass,
	new: () -> AnalyzerRegistryType,
}
export type AnalyzerRegistryType = {
	AudioPlayer: AudioPlayer,
	AudioAnalyzer: AudioAnalyzer,
	
	SetSoundId: ( AnalyzerRegistryType , SoundId: number   ) -> AnalyzerRegistryType,
	SetLooping: ( AnalyzerRegistryType , Looping: boolean? ) -> AnalyzerRegistryType,
}

-- // Functions

function AnalyzerRegistry:SetSoundId( SoundId: number )
	if type( SoundId ) ~= 'number' then
		warn( 'Could not assign AudioPlayer.Asset. Given SoundId is not a number.' )
		return self
	end
	self.AudioPlayer.Asset = string.format( '%s%d' , rbxassetid , Properties.SoundId )
end

function AnalyzerRegistry:SetLooping( Boolean: boolean? )
	self.AudioPlayer.Looping = Boolean or false
	return self
end

function AnalyzerRegistry.new()
	local AudioPlayer = Instance.new('AudioPlayer')
	--AudioPlayer.Parent =
	
	local AudioDeviceOutput = Instance.new('AudioDeviceOutput')
	AudioDeviceOutput.Parent = AudioPlayer
	local OutputWire = Instance.new('Wire')
	OutputWire.SourceInstance = AudioPlayer
	OutputWire.TargetInstance = AudioDeviceOutput
	OutputWire.Parent = AudioPlayer
	
	local AudioAnalyzer = Instance.new('AudioAnalyzer')
	AudioAnalyzer.WindowSize = Enum.AudioWindowSize.Large
	AudioAnalyzer.Parent = AudioPlayer
	local AnalyzeWire = Instance.new('Wire')
	AnalyzeWire.SourceInstance = AudioPlayer
	AnalyzeWire.TargetInstance = AudioAnalyzer
	AnalyzeWire.Parent = AudioPlayer
	
	return setmetatable( {
		AudioPlayer = AudioPlayer,
		AudioAnalyzer = AudioAnalyzer,
	} , AnalyzerRegistry )
end

return AnalyzerRegistry