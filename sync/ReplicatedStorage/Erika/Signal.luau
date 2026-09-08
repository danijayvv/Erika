--!strict
-- author is unknown, but this script can easily be swapped out for any other signal module

export type Connection = { Disconnect: (Connection) -> () }
export type Signal<T...> = {
	Connect: (Signal<T...>, (T...) -> ()) -> Connection,
	Once: (Signal<T...>, (T...) -> ()) -> Connection,
	Fire: (Signal<T...>, T...) -> (),
	Destroy: (Signal<T...>) -> (),
}
local Signal = {}
Signal.__index = Signal

type Listener<T...> = {
	callback: (T...) -> (),
	connected: boolean,
}
type SignalImpl<T...> = Signal<T...> & {
	_listeners: { Listener<T...> },
	_destroyed: boolean,
}

local function createConnection(disconnectFunction: () -> ()): Connection
	local connection = {} :: any
	local disconnected = false
	function connection:Disconnect()
		if disconnected then
			return
		end
		disconnected = true
		disconnectFunction()
	end
	return connection :: Connection
end

function Signal.new<T...>(): Signal<T...>
	local self = setmetatable({}, Signal) :: any
	self._listeners = {}
	self._destroyed = false
	return self
end

function Signal:Connect<T...>(callback: (T...) -> ()): Connection
	local selfImpl = self :: SignalImpl<T...>
	if selfImpl._destroyed then
		return createConnection(function() end)
	end
	local listener: Listener<T...> = { callback = callback, connected = true }
	local listeners = selfImpl._listeners
	listeners[#listeners + 1] = listener
	return createConnection(function()
		listener.connected = false
	end)
end

function Signal:Once<T...>(callback: (T...) -> ()): Connection
	local selfImpl = self :: SignalImpl<T...>
	if selfImpl._destroyed then
		return createConnection(function() end)
	end
	local listener: Listener<T...> = { callback = callback, connected = true }
	local listeners = selfImpl._listeners
	listeners[#listeners + 1] = listener
	local connection = createConnection(function()
		listener.connected = false
	end)
	local originalCallback = callback
	listener.callback = function(...: T...)
		listener.connected = false
		originalCallback(...)
	end
	return connection
end

function Signal:Fire<T...>(...: T...)
	local selfImpl = self :: SignalImpl<T...>
	if selfImpl._destroyed then
		return
	end
	for _, listener in ipairs(selfImpl._listeners) do
		if listener.connected then
			task.defer(listener.callback, ...)
		end
	end
end

function Signal:Destroy()
	local selfImpl = self :: SignalImpl<any>
	if selfImpl._destroyed then
		return
	end
	selfImpl._destroyed = true
	table.clear(selfImpl._listeners)
end

return Signal