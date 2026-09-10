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
export type BeatRegistryClass = {
	Bind  : ( AudioAnalyzer ) -> typeof( Signal.new() ),
	Unbind: ( AudioAnalyzer ) -> (),
}

type BandType = { Name: string , MinHz: number , MaxHz: number , DecayRate: number , StartBin: number , EndBin: number , Max: number }
type InfoType = {
	Signal: Signal.Signal<number>,
	Connection: Signal.Connection,
	Bands: { BandType },
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

function BeatRegistry.Bind( AudioAnalyzer: AudioAnalyzer )
	local OnBeat = Signal.new()
	local Bands = table.clone( FrequencyBands )
	for Index , Band in Bands do
		Bands[Index] = table.clone( Band )
	end

	local Connection = SpectrumRegistry.Bind( AudioAnalyzer ):Connect(function( RawValues: { number } )
		local Total = 0
		for __ , Band in Bands do
			Total += CalculateBand( RawValues , Band )
		end
		local Average = clamp( Total / #Bands , 0 , 1 )
		OnBeat:Fire( Average )
	end)
	Bindings[AudioAnalyzer] = { Signal = OnBeat, Bands = Bands, Connection = Connection }
	return OnBeat
end


function BeatRegistry.Unbind( AudioAnalyzer: AudioAnalyzer )
	local Info = Bindings[AudioAnalyzer]
	if not Info then
		return
	end
	Info.Connection:Disconnect()
	SpectrumRegistry.Unbind( AudioAnalyzer )
	Bindings[AudioAnalyzer] = nil
end

do
	for __ , Band in FrequencyBands do
		Band.StartBin = SpectrumRegistry.HzToRawBin( Band.MinHz )
		Band.EndBin   = SpectrumRegistry.HzToRawBin( Band.MaxHz )
	end
end

return BeatRegistry
