-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

const VisualizerBase = require('./VisualizerBase')
local Visualizer3D = setmetatable( {} , { __index = VisualizerBase } )
Visualizer3D.__index = Visualizer3D

-- // Services & Requires
const V3DDefaultInfo = require('@self/V3DDefaultInfo')
const V3DShapeData = require('@self/V3DShapeData')
const V3DTypes = require('@self/V3DTypes')

-- // Variables & Constants

-- // Tables & Types

-- // Functions

local GetBarPosition = function( self: VisualizerBase.VisualizerBaseType & V3DTypes.Visualizer3DType , Index: number ): Vector3
	local BarCount = self.BarCount
	local Callback = V3DShapeData.ShapeCallbacks[self.Shape]
	if not Callback then
		return self.Pivot
	end
	local T: number
	if BarCount <= 1 then
		T = 0
	elseif V3DShapeData.ClosedShapes[self.Shape] then
		T = ( Index - 1 ) / BarCount
	else
		T = ( Index - 1 ) / ( BarCount - 1 )
	end
	return Callback( self , T )
end

function Visualizer3D.new( AudioAnalyzer: AudioAnalyzer , Info: V3DTypes.Info3D , ParentInstance: Instance ): VisualizerBase.VisualizerBaseType & V3DTypes.Visualizer3DType
	local VisualizerContainer = Instance.new('Model')
	VisualizerContainer.Name = 'Visualizer3DContainer'
	VisualizerContainer.Parent = ParentInstance
	
	local MergedInfo = VisualizerBase.MergeDefaultInfo( V3DDefaultInfo , Info ) :: V3DTypes.Info3D & { [string]: any }
	local self = VisualizerBase.new( AudioAnalyzer , MergedInfo.BarCount , {
		VisualizerContainer = VisualizerContainer,
		Bars = {},
		
		BarDecay = MergedInfo.BarDecay,
		BarMaxHeight = MergedInfo.BarMaxHeight,
		BarColorLow = MergedInfo.BarColorLow,
		BarColorHigh = MergedInfo.BarColorHigh,
		
		BarThickness = MergedInfo.BarThickness,
		BarDepth = MergedInfo.BarDepth,
		LineSpacing = MergedInfo.LineSpacing,
		Pivot = MergedInfo.Pivot,
		Shape = MergedInfo.Shape,
		StartAngle = MergedInfo.StartAngle,
		Radius = MergedInfo.Radius,
		
		StarPoints = MergedInfo.StarPoints,
		StarInnerRadius = MergedInfo.StarInnerRadius,
		StarOuterRadius = MergedInfo.StarOuterRadius,
		PolygonSides = MergedInfo.PolygonSides,
		WaveFrequency = MergedInfo.WaveFrequency,
		WaveAmplitude = MergedInfo.WaveAmplitude,
		ArcAngle = MergedInfo.ArcAngle,
	} , MergedInfo.MinHz , MergedInfo.MaxHz )
	setmetatable( self :: any , Visualizer3D )
	
	for Index = 1 , MergedInfo.BarCount do
		local Bar = Instance.new('Part')
		Bar.Name = tostring( Index )
		Bar.Material = Enum.Material.SmoothPlastic
		Bar.Anchored = true
		Bar.CanCollide = false
		Bar.Size = Vector3.new( MergedInfo.BarThickness , 0.1 , MergedInfo.BarDepth )
		Bar.Color = MergedInfo.BarColorLow
		Bar.Parent = VisualizerContainer
		self.Bars[Index] = Bar
	end
	return self :: VisualizerBase.VisualizerBaseType & V3DTypes.Visualizer3DType
end

function Visualizer3D.RenderBar( self: VisualizerBase.VisualizerBaseType & V3DTypes.Visualizer3DType , Index: number , Value: number )
	local Bar = self.Bars[Index]
	if not Bar then
		return
	end
	local Normalized = math.clamp( Value , 0 , 1 )
	local Height = math.max( Normalized * self.BarMaxHeight , 0.05 )
	local Position = GetBarPosition( self , Index )
	Bar.Size = Vector3.new( self.BarThickness , Height , self.BarDepth )
	Bar.CFrame = CFrame.new( Position + Vector3.new( 0 , Height / 2 , 0 ) )
	Bar.Color = self.BarColorLow:Lerp( self.BarColorHigh , Normalized )
end

return Visualizer3D