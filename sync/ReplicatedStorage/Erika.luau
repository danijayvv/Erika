-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local Erika = {} :: ErikaClass
local ErikaConstructors = {} :: ErikaType & { __index: ErikaType }
ErikaConstructors.__index = ErikaConstructors

-- // Services & Requires
local AnalyzerRegistry   = require('@self/Registries/AnalyzerRegistry')
local BeatRegistry       = require('@self/Registries/BeatRegistry')
local Visualizer2D = require('@self/Registries/Visualizer/Visualizer2D')

local Signal = require('@self/Signal')

-- // Variables & Constants

-- // Tables & Types
export type ErikaClass = {
	new: ( Name: string? , AudioProperties: AnalyzerRegistry.AudioPropertiesType? ) -> ErikaType,
}
export type ErikaType = {
	AudioPlayer: AudioPlayer,
	Visualizers: { typeof( Visualizer2D.new( Instance.new('AudioAnalyzer') , {} , Instance.new('Frame') ) ) },
	AnalyzerEntry: typeof( AnalyzerRegistry.new{} ),
	OnBeat: Signal.Signal<number>,
	
	Set : ( ErikaType , SoundPropertiesType           ) -> ErikaType,
	Play: ( ErikaType , SoundPropertiesType? | number ) -> ErikaType,
	Stop: ( ErikaType , ResetTimePosition: boolean?   ) -> ErikaType,
	
	CreateVisualizer2D: ( ErikaType , ParentContainer: GuiObject , Info: Visualizer2D.Info2D? , AnchorPoint: Vector2? ) -> ErikaType,
	ClearVisualizers  : ( ErikaType ) -> ErikaType,
	
	SetBeatPreset: ( ErikaType , PresetName: BeatRegistry.PresetNameType ) -> ErikaType,
	Destroy: ( ErikaType ) -> (),
}

type SoundPropertiesType = {
	SoundId: number?,
	Looping: boolean?,
	PlaybackSpeed: number?,
	Volume: number?,
}

-- // Functions

local function SetSoundRelated( self: ErikaType , SoundProperties: SoundPropertiesType ): ErikaType
	self.AnalyzerEntry:SetSoundId( SoundProperties.SoundId )
	if type( SoundProperties.Looping ) == 'boolean' then
		self.AnalyzerEntry:SetLooping( SoundProperties.Looping )
	end
	self.AnalyzerEntry:SetPlaybackSpeed( SoundProperties.PlaybackSpeed )
	self.AnalyzerEntry:SetVolume( SoundProperties.Volume )
	return self
end
ErikaConstructors.Set = SetSoundRelated

function ErikaConstructors:Play( SoundProperties: SoundPropertiesType? | number ): ErikaType
	if type( SoundProperties ) == 'number' then
		self.AnalyzerEntry:SetSoundId( SoundProperties )
	elseif SoundProperties then
		SetSoundRelated( self , SoundProperties )
	end
	self.AudioPlayer:Play()
	return self
end

function ErikaConstructors:Stop( ResetTimePosition: boolean? ): ErikaType
	self.AudioPlayer:Stop()
	if ResetTimePosition then
		self.AudioPlayer.TimePosition = 0
	end
	return self
end

-- ==============================================

function ErikaConstructors:CreateVisualizer2D( ParentContainer: GuiObject , Info: Visualizer2D.Info2D? , AnchorPoint: Vector2? ): ErikaType
	local Visualizer = Visualizer2D.new( self.AnalyzerEntry.AudioAnalyzer , Info or {} , ParentContainer , AnchorPoint )
	table.insert( self.Visualizers , Visualizer )
	return self
end

function ErikaConstructors:ClearVisualizers()
	for __ , Visualizer in self.Visualizers do
		Visualizer:Destroy()
	end
	return self
end

-- ==============================================

function ErikaConstructors:SetBeatPreset( PresetName: BeatRegistry.PresetNameType ): ErikaType
	BeatRegistry.SetPreset( self.AnalyzerEntry.AudioAnalyzer , PresetName )
	return self
end

function ErikaConstructors:Destroy()
	self:ClearVisualizers()
	BeatRegistry.Unbind( self.AnalyzerEntry.AudioAnalyzer )
	self.AnalyzerEntry:Destroy()
end

function Erika.new( Name: string?, AudioProperties: AnalyzerRegistry.AudioPropertiesType? ): ErikaType
	local AnalyzerEntry = AnalyzerRegistry.new( AudioProperties or {} ):SetName( Name )
	return setmetatable( {
		AudioPlayer = AnalyzerEntry.AudioPlayer,
		Visualizers = {},
		AnalyzerEntry = AnalyzerEntry,
		OnBeat = BeatRegistry.Bind( AnalyzerEntry.AudioAnalyzer ),
	} :: ErikaType , ErikaConstructors )
end

return table.freeze( Erika )