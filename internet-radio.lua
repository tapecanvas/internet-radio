-- internet-radio
-- v0.1.13 (beta) @tapecanvas
-- inspired by:
-- @mlogger + @infinitedigits
-- with help from:
-- @eigen + github-copilot
-- llllllll.co/t/internet-radio/66152
--
-- internet radio player
-- built around mpv 
-- 
-- controls:
-- e2 scrolls through list
-- e3 mark stream as favorite
-- k3 plays stream 
-- k2 stops playback
--
-- params:
-- stream list 
-- exit option 
-- pitch
-- speed
--
-- *see "add your own streams" 
-- in the readme*

local current_stream = nil
local fileSelect = require('fileselect')
local selected_file = "/home/we/dust/data/internet-radio/streams/streams.lua"  
local current_stream_index = 1
local top_stream_index = 1
local is_playing = false
local exit_option = "close"
local streams = {}

-- load streams from the chosen stream list file
function load_streams()
    -- clear the streams array
    streams = {}
    local file = dofile(selected_file)
    if file then
        streams = file
        sort_streams()
    end
    -- reset the current stream index
    current_stream_index = 1 
    -- reset the top stream index
    top_stream_index = 1
    redraw()
end

-- save changes to streams.lua file (mostly just handling favorite status, but rewrites entire list to do it)
function save_streams()
    local file, err = io.open(selected_file, "w")
    if not file then
        print("Failed to open file: " .. err)
        return
    end
    file:write("return {\n")
    for _, stream in ipairs(streams) do
        file:write(string.format("    {name = \"%s\", address = \"%s\", favorite = %s},\n", stream.name, stream.address, tostring(stream.favorite)))
    end
    file:write("}\n")
    file:close()
end

-- the following sections move the contents of /code/internet-radio/lib to /data/internet-radio/streams if the included files are not already there
-- this allows the user to edit the streams.lua file in /data without making changes to the /code/internet-radio directory - which currently prevents updating from maiden  
-- inelegant but functional
--
-- function to check if files exists 
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then 
        io.close(f) 
        return true 
    else 
        return false 
    end
end

-- function to copy a file if it doesn't exist
function copy_stream_defaults(src, dst)
    if not file_exists(dst) then
        os.execute("mkdir -p /home/we/dust/data/internet-radio/streams/")
        os.execute(string.format("cp -n %s %s", src, dst))
    end
end

-- define the source and destination directories
local src_dir = "home/we/dust/code/internet-radio/lib/"
local dst_dir = "home/we/dust/data/internet-radio/streams/"

-- define file names to check for
local file_names = {"streams.lua", "template.lua", "bbc.lua"}

-- for each file, call the copy function to copy files from the src to the dst if they don't already exist there
for _, file_name in ipairs(file_names) do
    local src = src_dir .. file_name
    local dst = dst_dir .. file_name
    copy_stream_defaults(src, dst)
end
-- that ends the copy section

-- scroll through stream list
function scroll_streams(direction)
    current_stream_index = current_stream_index + direction
    if current_stream_index < 1 then
        current_stream_index = #streams
    elseif current_stream_index > #streams then
        current_stream_index = 1
    end

    if current_stream_index == 1 then
        top_stream_index = 1
    elseif current_stream_index < top_stream_index then
        top_stream_index = current_stream_index
    elseif current_stream_index > top_stream_index + 6 then
        top_stream_index = current_stream_index - 6
    end

    redraw()
end

-- play selected stream
-- no video: disable any video output from streams, audio channels stereo: force stereo output / make mono streams play in both channels, jack-port: sends stream audio into the crone input channels 
function play_stream()
    os.execute('killall mpv')
    if streams[current_stream_index] then
        local pitch = params:get("pitch")
        local speed = params:get("speed")
        os.execute('mpv --no-video --audio-channels=stereo  --jack-port="crone:input_(1|2)" --af=rubberband=pitch-scale=' .. pitch .. ' --speed=' .. speed ..' ' .. streams[current_stream_index].address .. ' &')
        is_playing = true
        playing_stream_index = current_stream_index
        -- Redraw the screen to show the play icon on the playing track
        redraw()
    end
end

-- stop the stream
function stop_stream()
    os.execute('killall mpv') -- killall -KILL mpv would force kill mpv with highest priority, but causes an audible beep/glitch when executed. so far this works fine as-is
    is_playing = false
    playing_stream_index = nil
    redraw()
end

-- toggle favorite status
function toggle_favorite()
    if streams[current_stream_index] then
        local favorited_stream = streams[current_stream_index]
        favorited_stream.favorite = not favorited_stream.favorite
        local was_playing = is_playing and streams[playing_stream_index]
        sort_streams()
        if was_playing then
            for i, stream in ipairs(streams) do
                if stream == was_playing then
                    playing_stream_index = i
                    break
                end
            end
        end
        -- If the stream was just favorited, find its new list position and move the cursor to that position (helps counter accidental multiple favorite selection)
        if favorited_stream.favorite then
            for i, stream in ipairs(streams) do
                if stream == favorited_stream then
                    current_stream_index = i
                    break
                end
            end
            -- Adjust the top_stream_index to ensure the favorited stream is visible 
            if current_stream_index < top_stream_index then
                top_stream_index = current_stream_index
            elseif current_stream_index >= top_stream_index + 7 then
                top_stream_index = current_stream_index - 6
            end
        end
        redraw()
    end
end

-- sort streams by favorite status and name
function sort_streams()
    local was_playing = is_playing and streams[playing_stream_index]
    table.sort(streams, function(a, b)
        if a.favorite and not b.favorite then
            return true
        elseif not a.favorite and b.favorite then
            return false
        else
            return a.name < b.name
        end
    end)
    if was_playing then
        for i, stream in ipairs(streams) do
            if stream == was_playing then
                playing_stream_index = i
                break
            end
        end
    end
    save_streams()
    redraw()
end

-- Save the current state to a file 
-- (if exit_option is "open", this will retain which stream is being played when you re-open the script)
function save_state()
    local file, err = io.open("/home/we/dust/data/internet-radio/state.lua", "w")
    if not file then
        print("Failed to open file: " .. err)
        return
    end
    file:write("return {\n")
    file:write(string.format("    current_stream_index = %d,\n", current_stream_index))
    file:write(string.format("    playing_stream_index = %d,\n", playing_stream_index))
    file:write(string.format("    exit_option = %d, \n", exit_option == "close" and 1 or 2))
    file:write(string.format("    selected_file = \"%s\",\n", selected_file))
    file:write("}\n")
    file:close()
end

-- Load the current state from a file
function load_state()
    local file
    local path = "/home/we/dust/data/internet-radio/state.lua"
    if not pcall(function() file = dofile(path) end) then
        -- if the file does not exist, create it with default values
        local default_file, err = io.open(path, "w")
        if not default_file then
            print("Failed to create file: " .. err)
            return
        end
        -- sets the default state
        default_file:write("return {\n")
        default_file:write("    current_stream_index = 1,\n")
        default_file:write("    playing_stream_index = nil,\n")
        default_file:write("    exit_option = 1,\n")
        default_file:write("    selected_file = \"/home/we/dust/data/internet-radio/streams/streams.lua\",\n")
        default_file:write("}\n")
        default_file:close()
        file = dofile(path)
    end
    if file then
        current_stream_index = file.current_stream_index or 1
        playing_stream_index = file.playing_stream_index
        exit_option = file.exit_option == 1 and "close" or "leave open"
        selected_file = file.selected_file or "/home/we/dust/data/internet-radio/streams/streams.lua"
    end
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
-- add resistance to "favorite" encoder to make it harder to select multiple favorites at once
norns.enc.sens(3,300) 

function enc(n,d)
    if n == 2 then
        scroll_streams(d)
    end
    if n == 3 then
        toggle_favorite(d)
    end
end

-- screen
function redraw()
    screen.clear()
    screen.aa(0)
    screen.font_face(1)
    for i = 1, 7 do
        local stream_index = top_stream_index + i - 1
        screen.font_size(8)
        if stream_index <= #streams then
            local stream = streams[stream_index]
            if stream_index == current_stream_index then
                -- highlight the stream under the scroll cursor in white
                screen.font_size(10)
                screen.level(15) -- Set the highlight color to white
                screen.rect(0, (i - 1) * 8, 128, 10) -- Draw a rectangle
                screen.fill() -- Fill the rectangle with white
                screen.level(0) -- Set the text color as black 
            elseif stream_index == playing_stream_index then
                -- highlight the currently playing stream in grey
                screen.level(5)
                screen.rect(0, (i - 1) * 8, 128, 10)
                screen.fill()
                screen.level(0)
            else
                screen.level(15) -- Set the text color as white
                screen.font_size(8)
            end
            screen.move(1, i * 8)
            -- add favorite and playing icons to the stream name if applicable
            screen.text((stream.favorite and '+' or ' ') .. (stream_index == playing_stream_index and '►' or '') .. stream.name)
        end
    end
    screen.update()
end

-- deinitialization 
-- if exit_option is "close" mpv is killed on script exit
function cleanup()
    save_state()
    if exit_option == "close" then
        stop_stream()
    end
end

function init()
    load_state()
    load_streams()

    -- select a stream list file
    params:add_separator("select stream list")
    params:add{type = "file", id = "stream_file", name = "stream list: ", path = selected_file,
    action = function(value)
        selected_file = value
        load_streams()
        playing_stream_index = nil -- remove playing icon when new list is selected (since list is different, this icon is irrelevant)+(continues to play the previously playing stream)
    end
    }

    -- set the exit option (how mpv will behave when another script is selected)
    -- "open" - script will continue playing when another script is selected (can run radio through effects, etc..)
    -- "close" - typical behavior, stops radio when another script is selected
    params:add_separator("open = leave mpv running")
    params:add{type = "option", id = "exit_option", name = "exit option: ", options = {"close", "leave open"}, default = exit_option == "close" and 1 or 2,
    action = function(value)
    exit_option = value == 1 and "close" or "leave open"
    end
    }

    -- pitch/speed params: 
    -- these are not real-time controls, they insert their values into the mpv play command. the stream will need to be re-started to hear the effect 
    -- since streams are broadcast in real time, increasing speed will cause gaps in audio while the stream catches up, you can work around this in creative ways though, experiment
    params:add_separator("pitch and speed")
    params:add_control("pitch", "pitch:", controlspec.new(-0.1, 3.0, 'lin', 0.02, 1, ""))
    params:add_control("speed", "speed:", controlspec.new(0.1, 2.0, 'lin', 0.02, 1, ""))

    -- remember which stream is playing if exit_option is "open" so it will be shown as playing when the script is re-opened
    if playing_stream_index and exit_option ~= "close" then
        current_stream_index = playing_stream_index
        redraw()
    else
        current_stream_index = 1
    end
end
