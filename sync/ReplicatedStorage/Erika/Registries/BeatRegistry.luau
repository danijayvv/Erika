-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local BeatRegistry = {} :: BeatRegistryClass

-- // Services & Requires
local SpectrumRegistry = require('./SpectrumRegistry')

local Signal = require('../Signal')

-- // Variables & Constants
const clamp = math.clamp
const max   = math.max

-- // Tables & Types
local Bindings: { [AudioAnalyzer]: BindType } = {}
local FrequencyBands: { BandType } = {
	{ Name = "Bass",    MinHz = 20,    MaxHz = 250,   DecayRate = 0.993 , StartBin = 0 , EndBin = 0 , Max = 0 },
	{ Name = "Beat",    MinHz = 250,   MaxHz = 500,   DecayRate = 0.990 , StartBin = 0 , EndBin = 0 , Max = 0 },
	{ Name = "Mellow",  MinHz = 500,   MaxHz = 2000,  DecayRate = 0.987 , StartBin = 0 , EndBin = 0 , Max = 0 },
	{ Name = "High",    MinHz = 2000,  MaxHz = 8000,  DecayRate = 0.983 , StartBin = 0 , EndBin = 0 , Max = 0 },
	{ Name = "Highest", MinHz = 8000,  MaxHz = 20000, DecayRate = 0.978 , StartBin = 0 , EndBin = 0 , Max = 0 },
}

export type PresetNameType = 'Default' | 'Punchy' | 'Subtle' | 'Smooth' | 'Gate_Lw' | 'Gate_Av' | 'Gate_Hi'
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
	Bind  : ( AudioAnalyzer , PresetName: PresetNameType? ) -> SubscriptionType,
	Unbind: ( AudioAnalyzer ) -> (),
	SetPreset: ( Subscription: SubscriptionType , PresetName: PresetNameType ) -> (),
}
export type SubscriptionType = {
	Signal: Signal.Signal<number>,
	Subscriber: SubscriberType,
	Disconnected: boolean,
	Disconnect: ( SubscriptionType ) -> (),
}

type BandType = { Name: string , MinHz: number , MaxHz: number , DecayRate: number , StartBin: number , EndBin: number , Max: number }
export type PresetType = {
	InputMin: number,
	InputMax: number,
	OutputMin: number,
	OutputMax: number,
	Threshold: number?,
}
type SubscriberType = {
	Signal: Signal.Signal<number>,
	Preset: PresetType,
	Connected: boolean,
}
type BindType = {
	Bands: { BandType },
	Connection: Signal.Connection,
	Subscribers: { SubscriberType },
}
type InfoType = {
	Bands: { BandType },
	Preset: PresetType,
}

-- // Functions

local function CalculateBand( RawValues: { number } , Band: BandType ): number
	local Sum, Count = 0, 0
	for Index = Band.StartBin , Band.EndBin do
		Sum += RawValues[Index] or 0
		Count += 1
	end
	local Value = Count > 0 and ( Sum / Count ) or 0
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

local function RemoveSubscriber( Info: BindType , Subscriber: SubscriberType )
	for Index = #Info.Subscribers , 1 , -1 do
		if Info.Subscribers[Index] ~= Subscriber then
			continue
		end
		table.remove( Info.Subscribers , Index )
		return
	end
end

local function DestroyBinding( AudioAnalyzer: AudioAnalyzer , Info: BindType )
	if Bindings[AudioAnalyzer] ~= Info then
		return
	end
	if Info.Connection then
		Info.Connection:Disconnect()
	end
	for __ , Subscriber in Info.Subscribers do
		Subscriber.Connected = false
		Subscriber.Signal:Destroy()
	end
	table.clear( Info.Subscribers )
	SpectrumRegistry.Unbind( AudioAnalyzer )
	Bindings[AudioAnalyzer] = nil
end

function BeatRegistry.Bind( AudioAnalyzer: AudioAnalyzer , PresetName: PresetNameType? ): SubscriptionType
	local Subscriber: SubscriberType = {
		Signal = Signal.new(),
		Preset = Presets[ PresetName or 'Default' :: PresetNameType ],
		Connected = true,
	}
	local Info: BindType = Bindings[AudioAnalyzer]
	if not Info then
		local Bands = table.clone( FrequencyBands )
		for Index , Band in Bands do
			Bands[Index] = table.clone( Band )
		end
		local NInfo = {
			Bands = Bands,
			Connection = nil :: any,
			Subscribers = {},
		} :: BindType
		Bindings[AudioAnalyzer] = NInfo
		
		NInfo.Connection = SpectrumRegistry.Bind( AudioAnalyzer ):Connect(function( Frame )
			local Total = 0
			for __ , Band in Bands do
				Total += CalculateBand( Frame.Values , Band )
			end
			local Average = clamp( Total / #NInfo.Bands , 0 , 1 )
			for Index = #NInfo.Subscribers , 1 , -1 do
				local Current = NInfo.Subscribers[Index]
				if not Current.Connected then
					table.remove( NInfo.Subscribers , Index )
				else
					local Value = Remap( Average , Current.Preset )
					Current.Signal:Fire( Value )
				end
			end
		end)
		Info = NInfo
	end
	table.insert( Info.Subscribers , Subscriber )
	
	local Subscription: SubscriptionType
	Subscription = {
		Signal = Subscriber.Signal,
		Subscriber = Subscriber,
		Disconnected = false,
		Disconnect = function()
			if Subscription.Disconnected then
				return
			end
			Subscription.Disconnected = true
			Subscriber.Connected = false
			RemoveSubscriber( Info , Subscriber )
			local CurrentInfo = Bindings[AudioAnalyzer]
			if CurrentInfo == Info and #Info.Subscribers == 0 then
				DestroyBinding( AudioAnalyzer , Info )
			end
		end,
	}
	return Subscription
end


function BeatRegistry.Unbind( AudioAnalyzer: AudioAnalyzer )
	local Info = Bindings[AudioAnalyzer]
	if not Info then
		return
	end
	DestroyBinding( AudioAnalyzer , Info )
end

function BeatRegistry.SetPreset( Subscription: SubscriptionType , PresetName: PresetNameType )
	if Subscription.Disconnected then
		return
	end
	local Preset = Presets[PresetName]
	if not Preset then
		return
	end
	Subscription.Subscriber.Preset = Preset
end

do
	for __ , Band in FrequencyBands do
		Band.StartBin = SpectrumRegistry.HzToRawBin( Band.MinHz )
		Band.EndBin   = SpectrumRegistry.HzToRawBin( Band.MaxHz )
	end
end

return BeatRegistry