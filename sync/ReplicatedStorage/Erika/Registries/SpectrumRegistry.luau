-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local SpectrumRegistry = {}

-- // Services & Requires
local RunService: RunService = game:GetService('RunService')
local Signal = require('../Signal')

-- // Variables & Constants
local RAW_BIN_COUNT = 128
local BIN_COUNT = 512
local HZ_PER_BIN = ( 44100 / 2 ) / BIN_COUNT
local MIN_HZ , MAX_HZ = 20 , 20000

SpectrumRegistry.RAW_BIN_COUNT = RAW_BIN_COUNT
SpectrumRegistry.MIN_HZ = MIN_HZ
SpectrumRegistry.MAX_HZ = MAX_HZ

const max = math.max
const min = math.min
local round = math.round

-- // Tables & Types
local Bindings: { [AudioAnalyzer]: { Signal: SignalType , AGCMax: number , RefCount: number } } = {}
local RawBinRanges = {}

type SignalType = Signal.Signal<{ number }, number>

-- // Functions

function SpectrumRegistry.HzToRawBin( Hz: number ): number
	local T = math.log( Hz / MIN_HZ ) / math.log( MAX_HZ / MIN_HZ )
	return max( 1 , min( RAW_BIN_COUNT , round( T * RAW_BIN_COUNT ) ) )
end

function SpectrumRegistry.Bind( AudioAnalyzer: AudioAnalyzer ): SignalType
	local Existing = Bindings[AudioAnalyzer]
	if Existing then
		Existing.RefCount += 1
		return Existing.Signal
	end

	local Changed = Signal.new()
	Bindings[AudioAnalyzer] = { Signal = Changed , AGCMax = 0.001 , RefCount = 1 }
	return Changed
end

function SpectrumRegistry.Unbind( AudioAnalyzer: AudioAnalyzer )
	local Info = Bindings[AudioAnalyzer]
	if not Info then
		return
	end
	Info.RefCount -= 1
	if Info.RefCount <= 0 then
		Bindings[AudioAnalyzer] = nil
	end
end

do
	for Index = 1, RAW_BIN_COUNT do
		local T0 = ( Index - 1 ) / RAW_BIN_COUNT
		local T1 = Index / RAW_BIN_COUNT
		local StartHz = MIN_HZ * ( MAX_HZ / MIN_HZ ) ^ T0
		local EndHz   = MIN_HZ * ( MAX_HZ / MIN_HZ ) ^ T1
		RawBinRanges[Index] = {
			StartBin = max( 1 , min( BIN_COUNT , round( StartHz / HZ_PER_BIN ) ) ),
			EndBin   = max( 1 , min( BIN_COUNT , round( EndHz   / HZ_PER_BIN ) ) ),
		}
	end
	
	RunService.RenderStepped:Connect(function()
		for AudioAnalyzer, Info in Bindings do
			local Spectrum = AudioAnalyzer:GetSpectrum()

			local RawValues = table.create( RAW_BIN_COUNT ) :: { number }
			local Peak = 0
			for Index = 1 , RAW_BIN_COUNT do
				local Range = RawBinRanges[Index]
				local Sum , Count = 0 , 0
				for Bin = Range.StartBin , Range.EndBin do
					Sum += Spectrum[Bin] or 0
					Count += 1
				end
				local Value = Count > 0 and Sum / Count or 0
				RawValues[Index] = Value
				if Value > Peak then
					Peak = Value
				end
			end

			Info.AGCMax = max( Info.AGCMax * 0.998 , 0.001 )
			if Peak > Info.AGCMax then
				Info.AGCMax = Peak
			end
			Info.Signal:Fire( RawValues , Info.AGCMax )
		end
	end)
end

return SpectrumRegistry