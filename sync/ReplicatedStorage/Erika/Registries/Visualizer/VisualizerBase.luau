-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local VisualizerBase = {}
VisualizerBase.__index = VisualizerBase

-- // Services & Requires
local SpectrumRegistry = require('../SpectrumRegistry')
local Signal = require('../../Signal')

-- // Variables & Constants
const RAW_BIN_COUNT = SpectrumRegistry.RAW_BIN_COUNT
const MIN_HZ = SpectrumRegistry.MIN_HZ
const MAX_HZ = SpectrumRegistry.MAX_HZ

const floor = math.floor
const round = math.round
const clamp = math.clamp
const max   = math.max
const min   = math.min
const log   = math.log

-- // Tables & Types
export type VisualizerBaseType = {
	AudioAnalyzer: AudioAnalyzer,
	BarCount: number,
	BarDecay: number,
	BarBinRanges: { BinRange },
	BarPeaks: { number },
	Connection: Signal.Connection?,

	RenderBar: ( self: VisualizerBaseType , Index: number , Value: number ) -> (),
	Destroy: ( self: VisualizerBaseType ) -> (),
}

export type BinRange = { StartBin: number, EndBin: number }

-- // Functions

local HzToRawBin = SpectrumRegistry.HzToRawBin
function VisualizerBase.new<T>( AudioAnalyzer: AudioAnalyzer , BarCount: number , BarDecay: number? , Addon: T ): VisualizerBaseType & T
	local BarBinRanges = table.create( BarCount ) :: { BinRange }
	for Index = 1 , BarCount do
		local T0 = ( Index - 1 ) / BarCount
		local T1 = Index / BarCount
		local StartHz = MIN_HZ * (MAX_HZ / MIN_HZ) ^ T0
		local EndHz   = MIN_HZ * (MAX_HZ / MIN_HZ) ^ T1
		BarBinRanges[Index] = { StartBin = HzToRawBin( StartHz ), EndBin = HzToRawBin( EndHz ) }
	end
	
	local Base = {
		AudioAnalyzer = AudioAnalyzer,
		BarCount = BarCount,
		BarDecay = BarDecay or 0.90,
		BarBinRanges = BarBinRanges,
		BarPeaks = table.create( BarCount , 0 ),
		Connection = nil,
	}
	for Key , Value in ( Addon :: { any } ) do
		Base[Key] = Value
	end

	local self = setmetatable( Base :: VisualizerBaseType , VisualizerBase )
	self.Connection = SpectrumRegistry.Bind( AudioAnalyzer ):Connect(function( RawValues: { number } , AGCMax: number )
		for Index = 1, self.BarCount do
			local Range = self.BarBinRanges[Index]
			local Sum , Count = 0, 0
			for Bin = Range.StartBin, Range.EndBin do
				Sum += RawValues[Bin] or 0
				Count += 1
			end
			local Value = clamp( ( Count > 0 and Sum / Count or 0 ) / AGCMax , 0 , 1 )
			self.BarPeaks[Index] *= self.BarDecay
			if Value > self.BarPeaks[Index] then
				self.BarPeaks[Index] = Value
			end
			self:RenderBar( Index , self.BarPeaks[Index] )
		end
	end)
	return self
end

function VisualizerBase:RenderBar( Index: number , Value: number )
	return
end

function VisualizerBase:Destroy()
	if self.Connection then
		self.Connection:Disconnect()
	end
	SpectrumRegistry.Unbind( self.AudioAnalyzer )
end

return VisualizerBase