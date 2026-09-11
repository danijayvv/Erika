-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local VisualizerBase = require('./VisualizerBase')
local Visualizer2D = setmetatable( {} , { __index = VisualizerBase } )
Visualizer2D.__index = Visualizer2D

-- // Services & Requires

-- // Variables & Constants

-- // Tables & Types
local DefaultInfo = table.freeze( {
	BarCount = 32,
	BarGap = 0.002,
	BarDecay = 0.9,
	BarMaxHeight = 0.95,
	BarColorLow = Color3.fromRGB( 0 , 0 , 255 ),
	BarColorHigh = Color3.fromRGB( 255 , 0 , 0 ),
} )

export type Info2D = {
	BarCount: number?,
	BarGap: number?,
	BarDecay: number?,
	BarMaxHeight: number?,
	BarColorLow: Color3?,
	BarColorHigh: Color3?,
}

export type AlignmentType = 'Top' | 'Bottom' | 'Center'
export type Visualizer2DType = Info2D & { VisualizerContainer: Frame , Bars: BarsType , BarWidth: number }
type BarsType = { [number]: Frame }

-- // Functions

function Visualizer2D.new( AudioAnalyzer: AudioAnalyzer , Info: Info2D , ParentContainer: GuiObject , ContainerAlignment: AlignmentType? , BarAlignment: AlignmentType? ): VisualizerBase.VisualizerBaseType & Visualizer2DType
	local VisualizerContainer = Instance.new('Frame')
	VisualizerContainer.Name = 'VisualizerContainer'
	
	VisualizerContainer.AnchorPoint = Vector2.new( 0.5 , 0.5 )
	VisualizerContainer.Position = UDim2.fromScale( 0.5 , ( ContainerAlignment == 'Top' and 0 ) or ( ContainerAlignment == 'Bottom' and 1 ) or 0.5 )
	
	VisualizerContainer.Size = UDim2.fromScale( 1 , 1 )
	VisualizerContainer.BackgroundTransparency = 1
	VisualizerContainer.LayoutOrder = -1
	VisualizerContainer.ZIndex = -1
	VisualizerContainer.Parent = ParentContainer
	
	local MergedInfo = table.clone( DefaultInfo ) :: Info2D & { [string]: any }
	for Key , Value in Info :: Info2D & { [string]: any } do
		MergedInfo[Key] = Value
	end
	
	local BarWidth = ( 1 / MergedInfo.BarCount ) - MergedInfo.BarGap
	local Bars: BarsType = {}
	for Index = 1, MergedInfo.BarCount do
		local Bar = Instance.new('Frame')
		
		Bar.AnchorPoint = ( BarAlignment == 'Top' and Vector2.new( 0 , 0 ) ) or ( BarAlignment == 'Bottom' and Vector2.new( 0 , 1 ) ) or Vector2.new( 0 , 0.5 )
		Bar.Position = UDim2.fromScale( ( Index - 1 ) / MergedInfo.BarCount , ( BarAlignment == 'Top' and -0.01 ) or ( BarAlignment == 'Bottom' and 1.01 ) or 0.5 )
		
		local IsBottom = Bar.AnchorPoint.Y >= 0.5
		Bar.Size = UDim2.fromScale( BarWidth , 0 )
		Bar.BackgroundTransparency = 0.5
		Bar.BackgroundColor3 = MergedInfo.BarColorLow
		Bar.BorderSizePixel = 0
		Bar.Parent = VisualizerContainer
		Bars[Index] = Bar
	end
	
	local self = VisualizerBase.new( AudioAnalyzer , MergedInfo.BarCount , {
		VisualizerContainer = VisualizerContainer,
		Bars = Bars,
		BarWidth = BarWidth,
		
		BarDecay = MergedInfo.BarDecay,
		BarMaxHeight = MergedInfo.BarMaxHeight,
		BarColorLow = MergedInfo.BarColorLow,
		BarColorHigh = MergedInfo.BarColorHigh,
	} )
	setmetatable( self :: any , Visualizer2D )
	return self
end

function Visualizer2D:RenderBar( Index: number , Value: number )
	self.Bars[Index].Size = UDim2.fromScale( self.BarWidth , Value * self.BarMaxHeight :: number )
	self.Bars[Index].BackgroundColor3 = self.BarColorLow:Lerp( self.BarColorHigh , Value )
end

return Visualizer2D
