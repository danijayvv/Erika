-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

local BeatRegistry = {} :: BeatRegistryClass

-- // Services & Requires
local RunService: RunService = game:GetService('RunService')

local Signal = require('../Signal')

-- // Variables & Constants

-- // Tables & Types
export type BeatRegistryClass = {
	Bind: () -> typeof( Signal.new() )
}

-- // Functions

function BeatRegistry.Bind()
	local OnBeat = Signal.new()
	
	return OnBeat
end

do
	RunService.RenderStepped:Connect(function()
		
	end)
end

return BeatRegistry
