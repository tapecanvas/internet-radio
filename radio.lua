local streams = {}
local current_stream = nil
FileSelect = require 'fileselect'
local current_stream_index = 1
local top_stream_index = 1
local is_playing = false

function add_stream(name, address)
    -- TODO: Implement
    table.insert(streams, {name = name, address = address})
end

streams = {}

function edit_stream(current_name, new_name, new_address)
    -- TODO: Implement
end

function delete_stream(name)
    -- TODO: Implement
end

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

function play_stream()
    if streams[current_stream_index] then
        os.execute('mpv ' .. streams[current_stream_index].address .. ' &')
        is_playing = true

         -- Update the parameters to reflect the current stream
         params:set("stream_name", streams[current_stream_index].name)
         params:set("stream_address", streams[current_stream_index].address)
    end
end

function stop_stream()
    os.execute('killall mpv')
    is_playing = false
end

function save_streams()
    local file, err = io.open("/home/we/dust/code/internet-radio/streams.txt", "w")
    if not file then
        file = io.open("/home/we/dust/code/internet-radio/streams.txt", "w")
    end
    if file then
        for _, stream in ipairs(streams) do
            file:write(stream.name .. "\n")
            file:write(stream.address .. "\n")
        end
        file:close()
    else
        print("Failed to open file: " .. err)
    end
end

function load_streams()
    local file = io.open("/home/we/dust/code/internet-radio/streams.txt", "r")
    if file then
        streams = {}
        while true do
            local name = file:read("*l")
            local address = file:read("*l")
            if name and address then
                table.insert(streams, {name = name, address = address})
            else
                break
            end
        end
        file:close()
    end
end    

function key(n,z)
    if n == 2 and z == 1 then
        if is_playing then
            stop_stream()
        else
        end
    end
    if n == 3 and z == 1 then
        if is_playing then
            stop_stream()
            play_stream()
        else
            play_stream()
        end
    end
end

function enc(n,d)
    if n == 3 then
        scroll_streams(d)
    end
end

function redraw()
  screen.clear()
  screen.aa(0)
--  screen.font_face(15)
  screen.font_face(15)
  screen.font_size(8)
  screen.level(15)
  for i = 1, 7 do
    local stream_index = top_stream_index + i - 1
    if stream_index <= #streams then
        local stream = streams[stream_index]
        if stream_index == current_stream_index then
            screen.level(15) -- Highlight the current stream
            screen.font_size(8)
        else
            screen.level(5) -- Dim other streams
            screen.font_size(7)
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
        action = function(value) streams[current_stream_index].name = value 
        save_streams() -- Save the changes
        end}

    params:add{type = "text", id = "stream_address", name = "",
        action = function(value) streams[current_stream_index].address = value 
        save_streams() -- Save the changes
        end}
    
        params:add_separator("add stream: (name,url)")  
    params:add{type = "text", id = "add_stream", name = "add stream: ",
        action = function(value)
        local name, address = string.match(value, "(.-),(.*)")
        if name and address then
            add_stream(name, address)
            save_streams() -- Save the changes
        end
    end
}

    params:set("stream_name", streams[current_stream_index].name)
    params:set("stream_address", streams[current_stream_index].address)
end