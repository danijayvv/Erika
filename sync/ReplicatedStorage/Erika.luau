-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local Erika = {}
Erika.__index = Erika

-- // Services & Requires
local AnalyzerRegistry = require('@self/AnalyzerRegistry')
local BeatRegistry     = require('@self/BeatRegistry')

-- // Variables & Constants

-- // Tables & Types
export type ErikaClass = {
	__index: ErikaClass,
}

export type ErikaPropertiesType = {
	Name: string?,
	
	WindowSize: Enum.AudioWindowSize?,
	SoundId: number,
	Looping: boolean?,
}

-- // Functions

function Erika:Play()
	-- AnalyzerRegistry:Play()
end

function Erika:Stop()
	
end

function Erika:Create()
	
end

function Erika.new( ErikaProperties: ErikaPropertiesType )
	local AnalyzerEntry = AnalyzerRegistry.new{ WindowSize = ErikaProperties.WindowSize }
		:SetSoundId( ErikaProperties.SoundId )
		:SetLooping( ErikaProperties.Looping )
		:SetName   ( ErikaProperties.Name    )
	
end

return Erika
