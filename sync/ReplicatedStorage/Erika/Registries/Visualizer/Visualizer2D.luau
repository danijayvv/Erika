-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

const VisualizerBase = require('./VisualizerBase')
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

export type AlignmentType = 'Top' | 'Bottom' | 'Center'

export type Info2D = VisualizerBase.InfoBase & {}
export type Visualizer2DType = Info2D & {
	VisualizerContainer: Frame,
	Bars: BarsType,
	BarWidth: number
} & typeof( DefaultInfo )
type BarsType = { [number]: Frame }

-- // Functions

function Visualizer2D.new( AudioAnalyzer: AudioAnalyzer , Info: Info2D , ParentContainer: GuiObject , ContainerAlignment: AlignmentType? , BarAlignment: AlignmentType? ): VisualizerBase.VisualizerBaseType & Visualizer2DType
	local VisualizerContainer = Instance.new('Frame')
	VisualizerContainer.Name = 'Visualizer2DContainer'
	
	VisualizerContainer.AnchorPoint = Vector2.new( 0.5 , 0.5 )
	VisualizerContainer.Position = UDim2.fromScale( 0.5 , ( ContainerAlignment == 'Top' and 0 ) or ( ContainerAlignment == 'Bottom' and 1 ) or 0.5 )
	
	VisualizerContainer.Size = UDim2.fromScale( 1 , 1 )
	VisualizerContainer.BackgroundTransparency = 1
	VisualizerContainer.LayoutOrder = -1
	VisualizerContainer.ZIndex = -1
	VisualizerContainer.Parent = ParentContainer
	
	local MergedInfo = VisualizerBase.MergeDefaultInfo( DefaultInfo , Info ) :: Info2D & { [string]: any }
	local BarCount = math.max( 1 , math.floor( MergedInfo.BarCount ) )
	local BarGap = math.clamp( MergedInfo.BarGap , 0 , 1 / BarCount - 0.001 )
	local self = VisualizerBase.new( AudioAnalyzer , BarCount , {
		VisualizerContainer = VisualizerContainer,
		Bars = {},
		BarWidth = ( 1 / BarCount ) - BarGap,
		
		BarGap = BarGap,
		BarDecay = math.clamp( MergedInfo.BarDecay , 0 , 1 ),
		BarMaxHeight = MergedInfo.BarMaxHeight,
		BarColorLow = MergedInfo.BarColorLow,
		BarColorHigh = MergedInfo.BarColorHigh,
	} , MergedInfo.MinHz , MergedInfo.MaxHz )
	setmetatable( self :: any , Visualizer2D )
	
	for Index = 1, MergedInfo.BarCount do
		local Bar = Instance.new('Frame')
		Bar.Name = tostring( Index )
		
		Bar.AnchorPoint = ( BarAlignment == 'Top' and Vector2.new( 0 , 0 ) ) or ( BarAlignment == 'Bottom' and Vector2.new( 0 , 1 ) ) or Vector2.new( 0 , 0.5 )
		Bar.Position = UDim2.fromScale( ( Index - 1 ) / MergedInfo.BarCount , ( BarAlignment == 'Top' and -0.01 ) or ( BarAlignment == 'Bottom' and 1.01 ) or 0.5 )
		
		Bar.Size = UDim2.fromScale( self.BarWidth , 0 )
		Bar.BackgroundTransparency = 0.5
		Bar.BackgroundColor3 = MergedInfo.BarColorLow
		Bar.BorderSizePixel = 0
		Bar.Parent = VisualizerContainer
		self.Bars[Index] = Bar
	end
	return self :: VisualizerBase.VisualizerBaseType & Visualizer2DType
end

function Visualizer2D:RenderBar( Index: number , Value: number )
	self.Bars[Index].Size = UDim2.fromScale( self.BarWidth , Value * self.BarMaxHeight :: number )
	self.Bars[Index].BackgroundColor3 = self.BarColorLow:Lerp( self.BarColorHigh , Value )
end

function Visualizer2D.Destroy( self: VisualizerBase.VisualizerBaseType & Visualizer2DType )
	if self._destroyed then
		return
	end
	VisualizerBase.Destroy( self :: any )
	if self.VisualizerContainer then
		self.VisualizerContainer:Destroy()
	end
end

return Visualizer2D
