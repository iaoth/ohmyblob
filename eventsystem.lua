event_queue = {}
event_funcs = {}

function queue_event(func,...)
	_add_event(#event_queue+1,func,...)
end

function clear_events()
	event_queue={}
end

function next_event(func,...)
	local group=2
	if #event_queue==0 then
		group=1
	else
		for i=#event_queue,2,-1 do
			event_queue[i+1]=event_queue[i]
		end
		event_queue[2]={}
	end
	_add_event(group,func,...)
end

function start_event(func,...)
	_add_event(1,func,...)
end

function group_event(func,...)
	_add_event(#event_queue,func,...)
end

function event_update()
	if #event_queue==0 then
		return
	end

	for co in all(event_queue[1]) do
		if costatus(co) == "dead" then
			del(event_queue[1],co)
		else
			coresume(co)
		end
	end

	if event_queue[1] and #event_queue[1]==0 then
		del(event_queue,event_queue[1])
	end
end

function _add_event(group,func,...)
--	printh("event:"..group..","..func)
	local co = cocreate(event_funcs[func])
	coresume(co,...)
	if (not event_queue[group]) event_queue[group]={}
	add(event_queue[group],co)
end
