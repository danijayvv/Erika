-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local AnalyzerRegistry = {} :: AnalyzerRegistryClass & AnalyzerRegistryType
AnalyzerRegistry.__index = AnalyzerRegistry

-- // Services & Requires
local SoundService: SoundService = game:GetService('SoundService')

-- // Variables & Constants
const rbxassetid = 'rbxassetid://'

-- // Tables & Types
export type AnalyzerRegistryClass = {
	__index: AnalyzerRegistryClass,
	new: ( AnalyzerRegistryProperties: AnalyzerRegistryPropertiesType ) -> AnalyzerRegistryType,
}
export type AnalyzerRegistryType = {
	AudioPlayer: AudioPlayer,
	AudioAnalyzer: AudioAnalyzer,
	
	SetName   : ( AnalyzerRegistryType , Name   : string?  ) -> AnalyzerRegistryType,
	SetSoundId: ( AnalyzerRegistryType , SoundId: number   ) -> AnalyzerRegistryType,
	SetLooping: ( AnalyzerRegistryType , Looping: boolean? ) -> AnalyzerRegistryType,
}

export type AnalyzerRegistryPropertiesType = {
	ExistingAudioPlayer: AudioPlayer?,
	ExistingAudioAnalyzer: AudioAnalyzer?,
	WindowSize: Enum.AudioWindowSize?
}

-- // Functions

function AnalyzerRegistry:SetName( Name: string? ): AnalyzerRegistryType
	if type( Name ) ~= 'string' then
		warn( 'Given Name is not a string.' )
		return self
	end
	self.AudioPlayer.Name = Name
	return self
end

function AnalyzerRegistry:SetSoundId( SoundId: number ): AnalyzerRegistryType
	if type( SoundId ) ~= 'number' then
		warn( 'Could not assign AudioPlayer.Asset. Given SoundId is not a number.' )
		return self
	end
	self.AudioPlayer.Asset = string.format( '%s%d' , rbxassetid , SoundId )
	return self
end

function AnalyzerRegistry:SetLooping( Boolean: boolean? ): AnalyzerRegistryType
	self.AudioPlayer.Looping = Boolean or false
	return self
end

function AnalyzerRegistry.new( AnalyzerRegistryProperties: AnalyzerRegistryPropertiesType )
	local AudioPlayer = AnalyzerRegistryProperties.ExistingAudioPlayer
	if not AudioPlayer then
		AudioPlayer = Instance.new('AudioPlayer')
		AudioPlayer.Parent = SoundService
		
		local AudioDeviceOutput = Instance.new('AudioDeviceOutput')
		AudioDeviceOutput.Parent = AudioPlayer
		local OutputWire = Instance.new('Wire')
		OutputWire.SourceInstance = AudioPlayer
		OutputWire.TargetInstance = AudioDeviceOutput
		OutputWire.Parent = AudioPlayer
	end
	
	local AudioAnalyzer = AnalyzerRegistryProperties.ExistingAudioAnalyzer
	if not AudioAnalyzer then
		AudioAnalyzer = Instance.new('AudioAnalyzer')
		AudioAnalyzer.WindowSize = AnalyzerRegistryProperties.WindowSize or Enum.AudioWindowSize.Large
		AudioAnalyzer.Parent = AudioPlayer
		local AnalyzeWire = Instance.new('Wire')
		AnalyzeWire.SourceInstance = AudioPlayer
		AnalyzeWire.TargetInstance = AudioAnalyzer
		AnalyzeWire.Parent = AudioPlayer
	end
	
	return setmetatable( {
		AudioPlayer = AudioPlayer,
		AudioAnalyzer = AudioAnalyzer,
	} :: AnalyzerRegistryType , AnalyzerRegistry )
end

return AnalyzerRegistry