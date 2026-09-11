-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local BeatRegistry = {} :: BeatRegistryClass

-- // Services & Requires
local SpectrumRegistry = require('./SpectrumRegistry')

local Signal = require('../Signal')

-- // Variables & Constants
const clamp = math.clamp
const max   = math.max
const min   = math.min
const round = math.round

-- // Tables & Types
local Bindings: { [AudioAnalyzer]: InfoType } = {}
local FrequencyBands: { BandType } = {
	{ Name = "Bass",    MinHz = 20,    MaxHz = 250,   DecayRate = 0.993 , StartBin = 0 , EndBin = 0 , Max = 0 },
	{ Name = "Beat",    MinHz = 250,   MaxHz = 500,   DecayRate = 0.990 , StartBin = 0 , EndBin = 0 , Max = 0 },
	{ Name = "Mellow",  MinHz = 500,   MaxHz = 2000,  DecayRate = 0.987 , StartBin = 0 , EndBin = 0 , Max = 0 },
	{ Name = "High",    MinHz = 2000,  MaxHz = 8000,  DecayRate = 0.983 , StartBin = 0 , EndBin = 0 , Max = 0 },
	{ Name = "Highest", MinHz = 8000,  MaxHz = 20000, DecayRate = 0.978 , StartBin = 0 , EndBin = 0 , Max = 0 },
}
local Presets: { [PresetNameType]: PresetType } = {
	['Default'] = { InputMin = 0,   InputMax = 1,   OutputMin = 0,   OutputMax = 1    },
	['Punchy']  = { InputMin = 0.3, InputMax = 0.8, OutputMin = 0.8, OutputMax = 1    },
	['Subtle']  = { InputMin = 0.2, InputMax = 0.9, OutputMin = 0.7, OutputMax = 0.85 },
	['Smooth']  = { InputMin = 0,   InputMax = 1,   OutputMin = 0.1, OutputMax = 0.6  },
	['Gate_Lw'] = { InputMin = 0,   InputMax = 1,   OutputMin = 0,   OutputMax = 1, Threshold = 0.5 },
	['Gate_Av'] = { InputMin = 0,   InputMax = 1,   OutputMin = 0,   OutputMax = 1, Threshold = 0.7 },
	['Gate_Hi'] = { InputMin = 0,   InputMax = 1,   OutputMin = 0,   OutputMax = 1, Threshold = 0.9 },
}

export type BeatRegistryClass = {
	Bind  : ( AudioAnalyzer , PresetName: PresetNameType? ) -> typeof( Signal.new() ),
	Unbind: ( AudioAnalyzer ) -> (),
	SetPreset: ( AudioAnalyzer , PresetName: PresetNameType ) -> (),
}

type BandType = { Name: string , MinHz: number , MaxHz: number , DecayRate: number , StartBin: number , EndBin: number , Max: number }
export type PresetNameType = 'Default' | 'Punchy' | 'Subtle' | 'Smooth' | 'Gate_Lw' | 'Gate_Av' | 'Gate_Hi'
export type PresetType = {
	InputMin: number,
	InputMax: number,
	OutputMin: number,
	OutputMax: number,
	Threshold: number?,
}
type InfoType = {
	Signal: Signal.Signal<number>,
	Connection: Signal.Connection?,
	Bands: { BandType },
	Preset: PresetType,
}

-- // Functions

local function CalculateBand( RawValues: { number } , Band: BandType ): number
	local Sum, Count = 0, 0
	for Index = Band.StartBin, Band.EndBin do
		Sum += RawValues[Index] or 0
		Count += 1
	end
	local Value = Count > 0 and Sum / Count or 0
	Band.Max = max( Value , Band.Max * Band.DecayRate )
	if Band.Max <= 0 then
		return 0
	end
	return clamp( Value / Band.Max , 0 , 1 )
end

local function Remap( Value: number , Preset: PresetType ): number
	local InMin , InMax = Preset.InputMin , Preset.InputMax
	if InMax <= InMin then
		return Preset.OutputMin
	end
	local T = clamp( ( Value - InMin ) / ( InMax - InMin ) , 0 , 1 )
	if Preset.Threshold then
		T = T >= Preset.Threshold and 1 or 0
	end
	return Preset.OutputMin + T * ( Preset.OutputMax - Preset.OutputMin )
end

function BeatRegistry.Bind( AudioAnalyzer: AudioAnalyzer , PresetName: PresetNameType? )
	local OnBeat = Signal.new()
	local Bands = table.clone( FrequencyBands )
	for Index , Band in Bands do
		Bands[Index] = table.clone( Band )
	end
	
	Bindings[AudioAnalyzer] = { Signal = OnBeat, Bands = Bands , Preset = PresetName and Presets[ PresetName :: PresetNameType ] or Presets.Default }
	Bindings[AudioAnalyzer].Connection = SpectrumRegistry.Bind( AudioAnalyzer ):Connect(function( RawValues: { number } )
		local Total = 0
		for __ , Band in Bands do
			Total += CalculateBand( RawValues , Band )
		end
		local Average = clamp( Total / #Bands , 0 , 1 )
		OnBeat:Fire( Remap( Average , Bindings[AudioAnalyzer].Preset ) )
	end)
	return OnBeat
end


function BeatRegistry.Unbind( AudioAnalyzer: AudioAnalyzer )
	local Info = Bindings[AudioAnalyzer]
	if not Info then
		return
	end
	if Info.Connection then
		Info.Connection:Disconnect()
	end
	SpectrumRegistry.Unbind( AudioAnalyzer )
	Bindings[AudioAnalyzer] = nil
end

function BeatRegistry.SetPreset( AudioAnalyzer: AudioAnalyzer , PresetName: PresetNameType )
	local Info = Bindings[AudioAnalyzer]
	if not Info then
		return
	end
	local Preset = Presets[PresetName]
	if not Preset then
		return
	end
	Info.Preset = Preset
end

do
	for __ , Band in FrequencyBands do
		Band.StartBin = SpectrumRegistry.HzToRawBin( Band.MinHz )
		Band.EndBin   = SpectrumRegistry.HzToRawBin( Band.MaxHz )
	end
end

return BeatRegistry
