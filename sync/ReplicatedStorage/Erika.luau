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
	new: ( ErikaProperties: ErikaPropertiesType ) -> ErikaType,
}
export type ErikaType = {
	AnalyzerEntry: typeof( AnalyzerRegistry.new{} ),
	OnBeat: Signal.Signal<number>,

	Play: ( ErikaType , SoundId: number? , Looping: boolean? , PlaybackSpeed: number? ) -> ErikaType,
	Stop: ( ErikaType ) -> ErikaType,
	Create: ( ErikaType ) -> ErikaType,
}

export type ErikaPropertiesType = {
	AnalyzerRegistryProperties: AnalyzerRegistry.AnalyzerRegistryPropertiesType?,
	SoundId: number?,
	Looping: boolean?,
	PlaybackSpeed: number?,
	Name: string?,
}

-- // Functions

function ErikaConstructors:Play( SoundId: number? , Looping: boolean? , PlaybackSpeed: number? )
	if SoundId then
		self.AnalyzerEntry:SetSoundId( SoundId )
	end
	if Looping then
		self.AnalyzerEntry:SetLooping( Looping )
	end
	self.AnalyzerEntry.AudioPlayer:Play()
	return self
end

function ErikaConstructors:Stop()
	self.AnalyzerEntry.AudioPlayer:Stop()
	return self
end

function ErikaConstructors:Create()
	return self
end

function Erika.new( ErikaProperties: ErikaPropertiesType )
	local AnalyzerEntry = AnalyzerRegistry.new( ErikaProperties.AnalyzerRegistryProperties or {} )
		:SetSoundId( ErikaProperties.SoundId )
		:SetLooping( ErikaProperties.Looping )
		:SetPlaybackSpeed( ErikaProperties.PlaybackSpeed )
		:SetName( ErikaProperties.Name )

	return setmetatable( {
		AnalyzerEntry = AnalyzerEntry,
		OnBeat = BeatRegistry.Bind( AnalyzerEntry.AudioAnalyzer ),
	} :: ErikaType , ErikaConstructors )
end

return table.freeze( Erika )