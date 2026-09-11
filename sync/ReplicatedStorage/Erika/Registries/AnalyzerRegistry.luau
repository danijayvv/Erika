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
	new: ( AudioProperties: AudioPropertiesType ) -> AnalyzerRegistryType,
}
export type AnalyzerRegistryType = {
	AudioPlayer: AudioPlayer,
	AudioAnalyzer: AudioAnalyzer,

	SetSoundId      : ( AnalyzerRegistryType , SoundId: number?       ) -> AnalyzerRegistryType,
	SetLooping      : ( AnalyzerRegistryType , Looping: boolean?      ) -> AnalyzerRegistryType,
	SetPlaybackSpeed: ( AnalyzerRegistryType , PlaybackSpeed: number? ) -> AnalyzerRegistryType,
	SetVolume       : ( AnalyzerRegistryType , Volume: number?        ) -> AnalyzerRegistryType,
	SetName         : ( AnalyzerRegistryType , Name: string?          ) -> AnalyzerRegistryType,
	
	Destroy: ( AnalyzerRegistryType ) -> (),
}

export type AudioPropertiesType = {
	AudioPlayer: AudioPlayer?,
	AudioAnalyzer: AudioAnalyzer?,
	WindowSize: Enum.AudioWindowSize?,
}

-- // Functions

local warnCNA = function( PropertyName: string , ParameterName: string | nil , Type: string )
	warn( string.format( 'Could not assign AudioPlayer.%s; given %s is not a %s.' , PropertyName , ParameterName or PropertyName , Type ) )
end

function AnalyzerRegistry:SetSoundId( SoundId: number? ): AnalyzerRegistryType
	if type( SoundId ) ~= 'number' then
		warnCNA( 'Asset' , 'SoundId' , 'number' )
		return self
	end
	self.AudioPlayer.Asset = string.format( '%s%d' , rbxassetid , SoundId )
	return self
end

function AnalyzerRegistry:SetLooping( Boolean: boolean? ): AnalyzerRegistryType
	self.AudioPlayer.Looping = Boolean or false
	return self
end

function AnalyzerRegistry:SetPlaybackSpeed( PlaybackSpeed: number? ): AnalyzerRegistryType
	if type( PlaybackSpeed ) ~= 'number' then
		warnCNA( 'PlaybackSpeed' , nil , 'number' )
		return self
	end
	self.AudioPlayer.PlaybackSpeed = PlaybackSpeed
	return self
end

function AnalyzerRegistry:SetVolume( Volume: number? ): AnalyzerRegistryType
	if type( Volume ) ~= 'number' then
		warnCNA( 'Volume' , nil , 'number' )
		return self
	end
	self.AudioPlayer.Volume = Volume or 0.5
	return self
end

function AnalyzerRegistry:SetName( Name: string? ): AnalyzerRegistryType
	if type( Name ) ~= 'string' then
		warnCNA( 'Name' , nil , 'string' )
		return self
	end
	self.AudioPlayer.Name = Name
	return self
end

-- ==============================================

function AnalyzerRegistry:Destroy()
	task.defer( self.AudioAnalyzer.Destroy , self.AudioAnalyzer )
	task.defer( self.AudioPlayer.Destroy , self.AudioPlayer )
	setmetatable( self , nil )
end

function AnalyzerRegistry.new( AudioProperties: AudioPropertiesType )
	local AudioPlayer = AudioProperties.AudioPlayer
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
	
	local AudioAnalyzer = AudioProperties.AudioAnalyzer
	if not AudioAnalyzer then
		AudioAnalyzer = Instance.new('AudioAnalyzer')
		AudioAnalyzer.WindowSize = AudioProperties.WindowSize or Enum.AudioWindowSize.Large
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