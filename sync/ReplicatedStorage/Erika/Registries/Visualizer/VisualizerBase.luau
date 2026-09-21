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

const clamp = math.clamp

-- // Tables & Types
export type VisualizerBaseType = {
	AudioAnalyzer: AudioAnalyzer,
	BarCount: number,
	BarDecay: number,
	BarBinRanges: { BinRange },
	BarPeaks: { number },
	Connection: Signal.Connection?,
	
	_destroyed: boolean,
	RenderBar: ( self: VisualizerBaseType , Index: number , Value: number ) -> (),
	Destroy: ( self: VisualizerBaseType ) -> (),
}

export type BinRange = { StartBin: number, EndBin: number }

-- // Functions

local function GetRangeAverage(PrefixValues: { number }, StartBin: number, EndBin: number): number
	local StartSum = StartBin > 1 and PrefixValues[StartBin - 1] or 0
	local Sum = PrefixValues[EndBin] - StartSum
	local Count = EndBin - StartBin + 1
	return Count > 0 and (Sum / Count) or 0
end

local HzToRawBin = SpectrumRegistry.HzToRawBin
function VisualizerBase.new<T>( AudioAnalyzer: AudioAnalyzer , BarCount: number , Addon: T , MinHz: number? , MaxHz: number? ): VisualizerBaseType & T
	local RangeMinHz = MinHz or MIN_HZ
	local RangeMaxHz = MaxHz or MAX_HZ
	local BarBinRanges = table.create( BarCount ) :: { BinRange }
	for Index = 1 , BarCount do
		local T0 = ( Index - 1 ) / BarCount
		local T1 = Index / BarCount
		local StartHz = RangeMinHz * ( RangeMaxHz / RangeMinHz ) ^ T0
		local EndHz   = RangeMinHz * ( RangeMaxHz / RangeMinHz ) ^ T1
		BarBinRanges[Index] = { StartBin = HzToRawBin( StartHz ) , EndBin = HzToRawBin( EndHz ) }
	end
	
	local Base = {
		AudioAnalyzer = AudioAnalyzer,
		BarCount = BarCount,
		BarDecay = ( Addon :: any ).BarDecay,
		BarBinRanges = BarBinRanges,
		BarPeaks = table.create( BarCount , 0 ),
		Connection = nil,
		
		_destroyed = false,
	}
	for Key , Value in ( Addon :: { [string]: any } ) do
		Base[Key] = Value
	end

	local self = setmetatable( Base :: VisualizerBaseType , VisualizerBase )
	self.Connection = SpectrumRegistry.Bind( AudioAnalyzer ):Connect(function( Frame )
		for Index = 1 , self.BarCount do
			local Range = self.BarBinRanges[Index]
			
			local Average = GetRangeAverage( Frame.PrefixValues , Range.StartBin , Range.EndBin )
			local Value = clamp( ( Average / Frame.AGCMax ) , 0 , 1 )
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
	if self._destroyed then
		return
	end
	( self :: VisualizerBaseType )._destroyed = true
	if self.Connection then
		self.Connection:Disconnect()
	end
	SpectrumRegistry.Unbind( self.AudioAnalyzer )
end

return VisualizerBase