![currentscreenshot](24-2-11screen.jpeg)
# this is a work in progress!
- **requires internet connection (wifi or ethernet) and mpv to be installed (not installed by default)**
    - to check/install mpv:
        - ssh into norns `ssh we@norns.local`
        - run `sudo apt install mpv`
    - OR from maiden `os.execute('sudo apt install mpv')` 
- a great use for norns when you're not actively making music on it
- also a test of github copilot
- inspired by @mlogger 's idea in https://llllllll.co/t/norns-ideas/17625/1328

# currently
### main controls
- e2 scrolls through list
- e3 favorites/unfavorites streams
- k3 plays selected stream (also stops previously playing stream before playing a new stream)
- k2 stops playback

### params menu
- edit stream name
- edit stream url
- add stream (see "add your own streams" below)

# add your own streams:
### method one (recommended)
- direct your browser of choice to maiden (yournornsip/maiden)
- go to `/code/internet-radio/streams.lua` file
- follow the format:
`{name = "stream name", address = "streamurl"},`

### method two 
- go to the params page
- use a usb keyboard(recommended) or e2 and e3 to enter the stream info in this format:
`stream name, https://yourstreamurlusuallyendingin-mp3`

# to-do
- [ ] more diverse default streams
- [ ] add default exit parameter option (close - kill mpv on new script load, or open - allow to keep playing and use as input for other scripts)
- [ ] volume control - depends on what I decide to do about input src vs passthough engine (see "radio as script" below)
- [x] way to favorite streams / bump to top of list
- [x] delete current stream option in params
- [x] update streams.lua documentation comments
- [x] verify add script from params page works (:
- [x] change scroll from e3 to e2
- [x] change streams.txt to streams.lua - easier to hide and add streams
- [x] radio as script / tape input (https://llllllll.co/t/norns-ideas/17625/1332) ty @infinitedigits as always (:
    - without doing this: mpv runs as a separate process(doesn't register in norns mixer or get recorded to tape)
    - doing this means you have to use 'monitor' mix to listen to radio as an input source - but I might have a way around this.. (simple in -> out engine, or leverage softcut somehow?)
    - makes sense since radio is not an engine, but a process that you're running on device.  
- [x] modify / rename option in params
- [x] keyboard/encoder input to add streams

