-- internet-radio
-- v0.1.1 @tapecanvas
-- inspired by:
-- @mlogger + @infinitedigits
-- with help from:
-- github-copilot
-- temp-lines-url
--
-- internet radio player
-- built with mpv 
-- 
-- controls:
-- e2 scrolls through list
-- k3 plays stream 
-- k2 stops playback
--
-- params:
-- edit stream name
-- edit stream url
-- add stream* 
-- *see "add your own streams" 
-- in the readme*

local streams = {}
local current_stream = nil
FileSelect = require 'fileselect'
local current_stream_index = 1
local top_stream_index = 1
local is_playing = false

-- initialize an empty stream array to load streams.txt into
streams = {}

-- add a new stream to the streams array
function add_stream(name, address)
   table.insert(streams, {name = name, address = address})
end

-- remove the current stream from the streams array *are you sure?*
function delete_stream()
    if streams[current_stream_index] then
        table.remove(streams, current_stream_index)
        save_streams()
        os.execute('killall mpv')
    end
end

-- load streams.lua file
function load_streams()
    local file = dofile("/home/we/dust/code/internet-radio/streams.lua")
    if file then
        streams = file
    end
end

-- save changes to streams.lua file
function save_streams()
    local file, err = io.open("/home/we/dust/code/internet-radio/streams.lua", "w")
    if not file then
        print("Failed to open file: " .. err)
        return
    end
    file:write("return {\n")
    for _, stream in ipairs(streams) do
        file:write(string.format("    {name = \"%s\", address = \"%s\"},\n", stream.name, stream.address))
    end
    file:write("}\n")
    file:close()
end

-- scroll through stream list
function scroll_streams(direction)
    current_stream_index = current_stream_index + direction
    if current_stream_index < 1 then
        current_stream_index = #streams
    elseif current_stream_index > #streams then
        current_stream_index = 1
    end

    if current_stream_index < top_stream_index then
        top_stream_index = current_stream_index
    elseif current_stream_index > top_stream_index + 6 then
        top_stream_index = current_stream_index - 6
    end

    redraw()
end

-- play selected stream
function play_stream()
    if streams[current_stream_index] then
        os.execute('mpv --no-video --jack-port="crone:input_(1|2)" ' .. streams[current_stream_index].address .. ' &')
        is_playing = true

         -- Update the parameters to reflect the current stream
         params:set("stream_name", streams[current_stream_index].name)
         params:set("stream_address", streams[current_stream_index].address)
    end
end

-- stop the stream
function stop_stream()
    os.execute('killall mpv')
    is_playing = false
end

-- keys
function key(n,z)
    if z == 1 then
        if n == 2 then
            if is_playing then stop_stream() end
        elseif n == 3 then
            if is_playing then stop_stream() end
            play_stream()
        end
    end
end

-- encoders
function enc(n,d)
    if n == 2 then
        scroll_streams(d)
    end
end

-- screen
function redraw()
  screen.clear()
  screen.aa(0)
  screen.font_face(1) --15
  screen.font_size(8)
  screen.level(15)
  for i = 1, 7 do
    local stream_index = top_stream_index + i - 1
    if stream_index <= #streams then
        local stream = streams[stream_index]
        if stream_index == current_stream_index then
            
            screen.level(15) -- Highlight the current stream
            screen.font_size(10)
        else
            screen.level(5) -- Dim other streams
            screen.font_size(8)
        end
        screen.move(1, i * 8)
        screen.text(stream.name)
    end
end
    screen.update()
end

function init()
    load_streams()
    current_stream_index = 1
    
    params:add_separator("edit cur. stream name or url")
    
    params:add{type = "text", id = "stream_name", name = "",
        action = function(value) 
            streams[current_stream_index].name = value 
            save_streams()
        end}

    params:add{type = "text", id = "stream_address", name = "",
        action = function(value) 
            streams[current_stream_index].address = value 
            save_streams()
        end}
    
    params:add_separator("add stream: (name,url)")  
    
    params:add{type = "text", id = "add_stream", name = "add stream",
        action = function(value)
            local name, address = string.match(value, "(.-),(.*)")
            if name and address then
                add_stream(name, address)
                save_streams() 
            end
        end
    }
    
    params:add_separator("delete current stream")
    
    params:add{type = "trigger", id = "delete_stream", name = "*delete current stream*",
    action = function(value)
        delete_stream()
        
    end
}

    -- Check that there is a current stream before setting the parameters
    if streams[current_stream_index] then
        params:set("stream_name", streams[current_stream_index].name)
        params:set("stream_address", streams[current_stream_index].address)
    end
end