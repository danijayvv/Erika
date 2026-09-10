-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local VisualizerBase = require('./VisualizerBase')
local Visualizer2D = setmetatable( {} , { __index = VisualizerBase } )
Visualizer2D.__index = Visualizer2D

-- // Services & Requires

-- // Variables & Constants

-- // Tables & Types
export type Info2D = {
	BarCount: number,
	BarGap: number,
	BarDecay: number?,
	BarMaxHeight: number?,
	BarColorLow: Color3,
	BarColorHigh: Color3,
}

-- // Functions

function Visualizer2D.new( AudioAnalyzer: AudioAnalyzer , Info: Info2D , ParentContainer: GuiObject , AnchorPoint: Vector2? )
	local VisualizerContainer = Instance.new('Frame')
	VisualizerContainer.Name = 'VisualizerContainer'
	VisualizerContainer.AnchorPoint = Vector2.new( 0.5 , 0.5 )
	VisualizerContainer.Size = UDim2.fromScale( 1 , 1 )
	VisualizerContainer.Position = UDim2.fromScale( 0.5 , 0.5 )
	VisualizerContainer.BackgroundTransparency = 1
	VisualizerContainer.LayoutOrder = -1
	VisualizerContainer.ZIndex = -1
	VisualizerContainer.Parent = ParentContainer
	
	local BarWidth = ( 1 / Info.BarCount ) - Info.BarGap
	local Bars = {}
	for Index = 1, Info.BarCount do
		local Bar = Instance.new('Frame')
		Bar.AnchorPoint = AnchorPoint or Vector2.new( 0 , 1 )
		local IsBottom = Bar.AnchorPoint.Y >= 0.5
		Bar.Size = UDim2.fromScale( BarWidth , 0 )
		Bar.Position = UDim2.fromScale( ( Index - 1 ) / Info.BarCount , ( IsBottom and 1 or 0 ) + ( IsBottom and 0.01 or -0.01 ) )
		Bar.BackgroundTransparency = 0.5
		Bar.BackgroundColor3 = Info.BarColorLow
		Bar.BorderSizePixel = 0
		Bar.Parent = VisualizerContainer
		Bars[Index] = Bar
	end
	
	local self = VisualizerBase.new( AudioAnalyzer , Info.BarCount , Info.BarDecay , {
		VisualizerContainer = VisualizerContainer,
		Bars = Bars,
		BarWidth = BarWidth,
		BarMaxHeight = Info.BarMaxHeight or 0.95,
		BarColorLow = Info.BarColorLow,
		BarColorHigh = Info.BarColorHigh,
	} )
	setmetatable( self :: any , Visualizer2D )
	return self
end

function Visualizer2D:RenderBar( Index: number , Value: number )
	self.Bars[Index].Size = UDim2.fromScale( self.BarWidth , Value * self.BarMaxHeight :: number )
	self.Bars[Index].BackgroundColor3 = self.BarColorLow:Lerp( self.BarColorHigh , Value )
end

return Visualizer2D
