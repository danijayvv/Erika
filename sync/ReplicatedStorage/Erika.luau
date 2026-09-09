-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local Erika = {} :: ErikaClass
local ErikaConstructors = {} :: ErikaType & { __index: ErikaType }
ErikaConstructors.__index = ErikaConstructors

-- // Services & Requires
local AnalyzerRegistry = require('./Erika/Registries/AnalyzerRegistry')
local BeatRegistry     = require('./Erika/Registries/BeatRegistry')

local Signal = require('./Erika/Signal')

-- // Variables & Constants

-- // Tables & Types
export type ErikaClass = {
	new: ( Name: string? , AudioProperties: AnalyzerRegistry.AudioPropertiesType? ) -> ErikaType,
}
export type ErikaType = {
	AnalyzerEntry: typeof( AnalyzerRegistry.new{} ),
	OnBeat: Signal.Signal<number>,
	
	Set: ( ErikaType , SoundPropertiesType ) -> ErikaType,
	Play: ( ErikaType , SoundPropertiesType | number ) -> ErikaType,
	Stop: ( ErikaType ) -> ErikaType,
	Create: ( ErikaType ) -> ErikaType,
}

type SoundPropertiesType = {
	SoundId: number?,
	Looping: boolean?,
	PlaybackSpeed: number?,
}

-- // Functions

local function SetSoundRelated( self: ErikaType , SoundProperties: SoundPropertiesType ): ErikaType
	if type( SoundProperties.SoundId ) == 'number' then
		self.AnalyzerEntry:SetSoundId( SoundProperties.SoundId )
	end
	if type( SoundProperties.Looping ) == 'boolean' then
		self.AnalyzerEntry:SetLooping( SoundProperties.Looping )
	end
	if type( SoundProperties.PlaybackSpeed ) == 'number' then
		self.AnalyzerEntry:SetPlaybackSpeed( SoundProperties.PlaybackSpeed )
	end
	return self
end
ErikaConstructors.Set = SetSoundRelated

function ErikaConstructors:Play( SoundProperties: SoundPropertiesType? | number ): ErikaType
	if type( SoundProperties ) == 'number' then
		self.AnalyzerEntry:SetSoundId( SoundProperties )
	elseif SoundProperties then
		SetSoundRelated( self , SoundProperties )
	end
	self.AnalyzerEntry.AudioPlayer:Play()
	return self
end

function ErikaConstructors:Stop(): ErikaType
	self.AnalyzerEntry.AudioPlayer:Stop()
	return self
end

function ErikaConstructors:Create(): ErikaType
	return self
end

function Erika.new( Name: string?, AudioProperties: AnalyzerRegistry.AudioPropertiesType? )
	local AnalyzerEntry = AnalyzerRegistry.new( AudioProperties or {} ):SetName( Name )
	
	return setmetatable( {
		AnalyzerEntry = AnalyzerEntry,
		OnBeat = BeatRegistry.Bind( AnalyzerEntry.AudioAnalyzer ),
	} :: ErikaType , ErikaConstructors )
end

return table.freeze( Erika )