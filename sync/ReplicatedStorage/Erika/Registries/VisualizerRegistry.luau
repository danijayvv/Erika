-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local VisualizerRegistry = {}

-- // Services & Requires

-- // Variables & Constants

-- // Tables & Types
type VisualizerInfoType = {
	BarCount: number,
	BarGap: number,
	BarDecay: number,
	BarMaxHeight: number,
	BarColorLow: Color3,
	BarColorHigh: Color3,
}

-- // Functions

function VisualizerRegistry.new( VisualizerInfo: VisualizerInfoType , ParentContainer: GuiObject )
	local VisualizerContainer = Instance.new('Frame')
	VisualizerContainer.Name = 'VisualizerContainer'
	VisualizerContainer.AnchorPoint = Vector2.new(0.5,0.5)
	VisualizerContainer.Size = UDim2.fromScale(1, 1)
	VisualizerContainer.Position = UDim2.fromScale(0.5, 0.5)
	VisualizerContainer.BackgroundTransparency = 1
	VisualizerContainer.LayoutOrder = -1
	VisualizerContainer.ZIndex = -1
	VisualizerContainer.Parent = ParentContainer
end

do
	
end

return VisualizerRegistry