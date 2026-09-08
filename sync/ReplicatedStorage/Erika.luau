-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local Erika = {}
Erika.__index = Erika

-- // Services & Requires
local SoundService: SoundService = game:GetService('SoundService')

local AnalyzerRegistry = require('@self/AnalyzerRegistry')

-- // Variables & Constants

-- // Tables & Types
export type ErikaClass = {
	__index: ErikaClass,
	Parent: Folder,
}

export type ErikaPropertiesType = {
	SoundId: number,
	Looping: boolean?,
}

-- // Functions

function Erika.new( ErikaProperties: ErikaPropertiesType )
	local AnalyzerEntry = AnalyzerRegistry.new()
		:SetSoundId( ErikaProperties.SoundId )
		:SetLooping( ErikaProperties.Looping )
end

do
	local Folder = Instance.new('Folder')
	Folder.Name = 'Erika'
	Folder.Parent = SoundService
	Erika.Parent = Folder
end

return Erika
