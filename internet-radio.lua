-- internet-radio
-- v0.1.9b (beta) @tapecanvas
-- inspired by:
-- @mlogger + @infinitedigits
-- with help from:
-- github-copilot + @eigen
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
-- edit stream name
-- edit stream url
-- add stream* 
-- delete current stream
-- *see "add your own streams" 
-- in the readme*

local current_stream = nil
FileSelect = require 'fileselect'
local selected_file = "/home/we/dust/data/internet-radio/streams.lua"  
local current_stream_index = 1
local top_stream_index = 1
local is_playing = false
local exit_option = "close"


-- initialize an empty stream array to load streams.lua into
local streams = {}

-- add a new stream to the streams array
function add_stream(name, address)
   table.insert(streams, {name = name, address = address, favorite = false})
end

-- remove the current stream from the streams array *are you sure?*
function delete_stream()
    if streams[current_stream_index] then
        table.remove(streams, current_stream_index)
        save_streams()
        os.execute('killall mpv')
    end
end

-- load streams from streams.lua file
function load_streams()
    streams = {} -- clear the streams array
    local file = dofile(selected_file)
    if file then
        streams = file
        sort_streams() -- sort the streams after loading them
    end
    current_stream_index = 1 -- reset the current stream index
    top_stream_index = 1 -- reset the top stream index
    redraw()
end

-- save changes to streams.lua file
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

-- this block moves the contents of /code/internet-radio/lib to /data/internet-radio/streams if the included files are not already there
-- this allows the user to edit the streams.lua file without making changes to the /code/internet-radio directory - which currently prevents updating from maiden  
-- inelegant but functional
-- 
-- function to check if a file exists 
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
        os.execute(string.format("cp -n %s %s", src, dst))
    end
end

-- define the source and destination directories
local src_dir = "home/we/dust/code/internet-radio/lib/"
local dst_dir = "home/we/dust/data/internet-radio/"

-- define file names to check for
local file_names = {"streams.lua", "template.lua", "bbc.lua"}

-- for each file, call the copy function to copy files from the src to the dst if they don't already exist there
for _, file_name in ipairs(file_names) do
    local src = src_dir .. file_name
    local dst = dst_dir .. file_name
    copy_stream_defaults(src, dst)
end
--

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
        playing_stream_index = current_stream_index

        -- Update the parameters to reflect the current stream
        params:set("stream_name", streams[current_stream_index].name)
        params:set("stream_address", streams[current_stream_index].address)

        -- Redraw the screen to show the play icon on the playing track
        redraw()
    end
end

-- stop the stream
function stop_stream()
    os.execute('killall mpv')
    is_playing = false
    playing_stream_index = nil
    redraw()
end

-- toggle favorite status
function toggle_favorite()
    if streams[current_stream_index] then
        streams[current_stream_index].favorite = not streams[current_stream_index].favorite
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

-- Save the current state to a file (if exit_option is "open", this will retain which stream is being played when you re-open the script)
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
        -- If the file does not exist, create it with default values
        local default_file, err = io.open(path, "w")
        if not default_file then
            print("Failed to create file: " .. err)
            return
        end
        default_file:write("return {\n")
        default_file:write("    current_stream_index = 1,\n")
        default_file:write("    playing_stream_index = nil,\n")
        default_file:write("    exit_option = 1,\n")
        default_file:write("    selected_file = \"/home/we/dust/data/internet-radio/streams.lua\",\n")  -- updated
        default_file:write("}\n")
        default_file:close()
        file = dofile(path)
    end
    if file then
        current_stream_index = file.current_stream_index or 1
        playing_stream_index = file.playing_stream_index
        exit_option = file.exit_option == 1 and "close" or "leave open"
        selected_file = file.selected_file or "/home/we/dust/data/internet-radio/streams.lua"  -- updated
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
function enc(n,d)
    if n == 2 then
        scroll_streams(d)
    end
    if n == 3 then
        toggle_favorite()
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
            elseif is_playing and stream_index == playing_stream_index then
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
            screen.text((stream.favorite and '+' or ' ') .. (is_playing and stream_index == playing_stream_index and '►' or '') .. stream.name)
        end
    end
    screen.update()
end

-- deinitialization 
-- stop mpv or leave running when another script is selected 
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

    -- edit the stream name
    params:add_separator("edit current stream")
    params:add{type = "text", id = "stream_name", name = "",
        action = function(value) 
            streams[current_stream_index].name = value
            save_streams()
        end
    }

    -- edit the stream url
    params:add{type = "text", id = "stream_address", name = "",
     action = function(value)
         streams[current_stream_index].address = value
         save_streams()
     end
    }

    -- add a new stream to the current list of streams
    params:add_separator("add stream: (name,url)")
    params:add{type = "text", id = "add_stream: ", name = "add stream",
        action = function(value)
            local name, address = string.match(value, "(.-),(.*)")
            if name and address then
                add_stream(name, address)
                save_streams()
            end
        end
    }

    -- delete the current stream from the stream list
    params:add_separator("delete current stream")
    params:add{type = "trigger", id = "delete_stream", name = " ***delete current stream***",
    action = function(value)
        delete_stream()
        end
    }

    -- Check that there is a current stream before setting the parameters
    if streams[current_stream_index] then
        params:set("stream_name", streams[current_stream_index].name)
        params:set("stream_address", streams[current_stream_index].address)
    end
    -- remember which stream is playing if exit_option is "open" so it will be shown as playing when the script is re-opened
    if playing_stream_index and exit_option ~= "close" then
        current_stream_index = playing_stream_index
        play_stream()
    else
        current_stream_index = 1
    end
end
-- Will wonders never cease?
