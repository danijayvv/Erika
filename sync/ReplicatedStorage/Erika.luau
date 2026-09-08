-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local Erika = {} :: ErikaClass
local ErikaConstructors = {} :: ErikaType & { __index: ErikaType }
ErikaConstructors.__index = ErikaConstructors

-- // Services & Requires
local AnalyzerRegistry = require('@self/Registries/AnalyzerRegistry')
local BeatRegistry     = require('@self/Registries/BeatRegistry')

local Signal = require('@self/Signal')

-- // Variables & Constants

-- // Tables & Types
export type ErikaClass = {
	new: ( ErikaProperties: ErikaPropertiesType ) -> ErikaType,
}
export type ErikaType = {
	AnalyzerEntry: typeof( AnalyzerRegistry.new{} ),
	OnBeat: typeof( Signal.new() ),
	
	Play: ( ErikaType , SoundId: number? ) -> ErikaType,
	Stop: ( ErikaType                    ) -> ErikaType,
	Create: ( ErikaType ) -> ErikaType,
}

export type ErikaPropertiesType = {
	Name: string?,
	
	AnalyzerRegistryPropertiesType: AnalyzerRegistry.AnalyzerRegistryPropertiesType,
	SoundId: number,
	Looping: boolean?,
}

-- // Functions

function ErikaConstructors:Play( SoundId: number? )
	if SoundId then
		self.AnalyzerEntry:SetSoundId( SoundId )
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
	local AnalyzerEntry = AnalyzerRegistry.new( ErikaProperties.AnalyzerRegistryPropertiesType )
		:SetSoundId( ErikaProperties.SoundId )
		:SetLooping( ErikaProperties.Looping )
		:SetName   ( ErikaProperties.Name    )
	
	return setmetatable( {
		AnalyzerEntry = AnalyzerEntry,
		OnBeat = BeatRegistry.Bind(),
	} :: ErikaType , ErikaConstructors )
end

return table.freeze( Erika )