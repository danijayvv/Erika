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
local MinHz , MaxHz = 20 , 20000

const max = math.max
const min = math.min
local round = math.round

-- // Tables & Types
local Bindings = {}
local RawBinRanges = {}

-- // Functions

function SpectrumRegistry.Bind( AudioAnalyzer: AudioAnalyzer ): Signal.Signal<{ number }, number>
	local Changed = Signal.new()
	Bindings[AudioAnalyzer] = { Signal = Changed , AGCMax = 0.001 }
	return Changed
end
function SpectrumRegistry.Unbind( AudioAnalyzer: AudioAnalyzer )
	Bindings[AudioAnalyzer] = nil
end

do
	for Index = 1, RAW_BIN_COUNT do
		local T0 = ( Index - 1 ) / RAW_BIN_COUNT
		local T1 = Index / RAW_BIN_COUNT
		local StartHz = MinHz * ( MaxHz / MinHz ) ^ T0
		local EndHz   = MinHz * ( MaxHz / MinHz ) ^ T1
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