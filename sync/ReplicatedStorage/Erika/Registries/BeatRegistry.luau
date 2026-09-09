-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local BeatRegistry = {} :: BeatRegistryClass

-- // Services & Requires
local RunService: RunService = game:GetService('RunService')

local Signal = require('../Signal')

-- // Variables & Constants
const floor = math.floor
const round = math.round
const clamp = math.clamp
const max   = math.max
const min   = math.min

const SAMPLE_RATE = 44100
const BIN_COUNT   = 512
const HZ_PER_BIN  = ( SAMPLE_RATE / 2 ) / BIN_COUNT
const AGC_DECAY = 0.998
const AGC_MIN   = 0.01
const SCALE_MULTIPLIER = 0.5

-- // Tables & Types
local Bindings: { [AudioAnalyzer]: InfoType } = {}
local FrequencyBands: { FrequencyBandType } = {
	{ Name = "Bass",    MinHz = 20,    MaxHz = 250,   DecayRate = 0.993 , StartBin = 0 , EndBin = 0 , BinCount = 0 , Max = 0 },
	{ Name = "Beat",    MinHz = 250,   MaxHz = 500,   DecayRate = 0.990 , StartBin = 0 , EndBin = 0 , BinCount = 0 , Max = 0 },
	{ Name = "Mellow",  MinHz = 500,   MaxHz = 2000,  DecayRate = 0.987 , StartBin = 0 , EndBin = 0 , BinCount = 0 , Max = 0 },
	{ Name = "High",    MinHz = 2000,  MaxHz = 8000,  DecayRate = 0.983 , StartBin = 0 , EndBin = 0 , BinCount = 0 , Max = 0 },
	{ Name = "Highest", MinHz = 8000,  MaxHz = 20000, DecayRate = 0.978 , StartBin = 0 , EndBin = 0 , BinCount = 0 , Max = 0 },
}

export type BeatRegistryClass = {
	Bind  : ( AudioAnalyzer ) -> typeof( Signal.new() ),
	Unbind: ( AudioAnalyzer ) -> (),
}

type FrequencyBandType = {
	Name: string,
	MinHz: number,
	MaxHz: number,
	DecayRate: number,
	StartBin: number,
	EndBin: number,
	BinCount: number,
	Max: number,
}

type InfoType = {
	Signal: typeof( Signal.new() ),
	FrequencyBands: typeof( FrequencyBands ),
	AGCMax: number,
}

-- // Functions

function BeatRegistry.Bind( AudioAnalyzer: AudioAnalyzer )
	local OnBeat = Signal.new()
	Bindings[AudioAnalyzer] = {
		Signal = OnBeat,
		FrequencyBands = table.clone( FrequencyBands ),
		AGCMax = 0.001,
	}
	return OnBeat
end

function BeatRegistry.Unbind( AudioAnalyzer: AudioAnalyzer )
	if not Bindings[AudioAnalyzer] then
		return
	end
	Bindings[AudioAnalyzer] = nil
end

-- ==============================================

local function CalculateBand( Spectrum: { number } , Band: FrequencyBandType ): number
	local Sum = 0
	for Index = Band.StartBin, Band.EndBin do
		Sum += Spectrum[Index] or 0
	end
	local Value = clamp( Sum / Band.BinCount , 0 , 1 )
	Band.Max *= Band.DecayRate
	if Value > Band.Max then
		Band.Max = Value
	end
	return clamp( Band.Max * 2 , 0 , 1 )
end

local UponRenderStep = function( Spectrum: { any } , Info: InfoType )
	local Total = 0
	for __ , Band in Info.FrequencyBands do
		Total += CalculateBand( Spectrum , Band )
	end

	local Average = clamp( Total / #Info.FrequencyBands , 0 , 1 )
	Info.AGCMax = max( Info.AGCMax * AGC_DECAY , AGC_MIN )
	if Average > Info.AGCMax then
		Info.AGCMax = Average
	end
	local Normalized = clamp( Average / Info.AGCMax , 0 , 1 )
	Info.Signal:Fire( Normalized )
end

local function FreqToBin( Hz: number ): number
	return max( 1 , min( BIN_COUNT , round( Hz / HZ_PER_BIN ) ) )
end

do
	for __ , Band in FrequencyBands do
		Band.StartBin = FreqToBin( Band.MinHz )
		Band.EndBin   = FreqToBin( Band.MaxHz )
		Band.BinCount = ( Band.EndBin :: number ) - ( Band.StartBin :: number ) + 1
	end
	
	RunService.RenderStepped:Connect(function()
		for AudioAnalyzer , Info in Bindings do
			UponRenderStep( AudioAnalyzer:GetSpectrum() , Info )
		end
	end)
end

return BeatRegistry
