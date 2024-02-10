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

-- hardcode the streams for now
streams = {
    {name = "SomaFM - Groove Salad", address = "http://ice1.somafm.com/groovesalad-128-mp3"},
    {name = "SomaFM - Lush", address = "http://ice1.somafm.com/lush-128-mp3"},
    {name = "SomaFM - Secret Agent", address = "http://ice1.somafm.com/secretagent-128-mp3"},
    {name = "SomaFM - Space Station Soma", address = "http://ice1.somafm.com/spacestation-128-mp3"},
    {name = "SomaFM - Suburbs of Goa", address = "http://ice1.somafm.com/suburbsofgoa-128-mp3"},
    {name = "SomaFM - The Trip", address = "http://ice1.somafm.com/thetrip-128-mp3"},
    {name = "SomaFM - Underground 80s", address = "http://ice1.somafm.com/u80s-128-mp3"},
    {name = "SomaFM - PopTron", address = "http://ice1.somafm.com/poptron-128-mp3"},
    {name = "SomaFM - DEF CON Radio", address = "http://ice1.somafm.com/defcon-128-mp3"},
    {name = "SomaFM - Digitalis", address = "http://ice1.somafm.com/digitalis-128-mp3"},
    {name = "SomaFM - Boot Liquor", address = "http://ice1.somafm.com/bootliquor-128-mp3"},
    {name = "SomaFM - Illinois Street Lounge", address = "http://ice1.somafm.com/illstreet-128-mp3"},
    {name = "SomaFM - Seven Inch Soul", address = "http://ice1.somafm.com/seveninch-128-mp3"},
    {name = "SomaFM - Sonic Universe", address = "http://ice1.somafm.com/sonicuniverse-128-mp3"}
}

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
    elseif current_stream_index > top_stream_index + 7 then
        top_stream_index = current_stream_index - 7
    end
    redraw()
end

function play_stream()
    if streams[current_stream_index] then
        os.execute('mpv ' .. streams[current_stream_index].address .. ' &')
        is_playing = true
    end
end

function stop_stream()
    os.execute('killall mpv')
    is_playing = false
end



function save_streams()
    -- TODO: Implement
end

function load_streams()
    -- TODO: Implement
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
  screen.font_face(15)
  screen.font_size(8)
  screen.level(15)
  for i = 0, 7 do
    local stream_index = top_stream_index + i
    if stream_index <= #streams then
        local stream = streams[stream_index]
        if stream_index == current_stream_index then
            screen.level(15) -- Highlight the current stream
        else
            screen.level(5) -- Dim other streams
        end
        screen.move(0, i * 8)
        screen.text(stream.name)
    end
end
    screen.update()
end

function init()
    load_streams()
end