# this is a work in progress!
- **requires internet connection (wifi or ethernet) and mpv to be installed (not sure if it's installed by default?)**
    - to check/install mpv:
        - ssh into norns `ssh we@norns.local`
        - run `sudo apt install mpv` 
- a great use for norns when you're not actively making music on it
- also a test of github copilot
- inspired by @mlogger 's idea in https://llllllll.co/t/norns-ideas/17625/1328

# currently
### main controls
- E3 scrolls through list
- K3 plays selected stream (also stops previously playing stream before playing a new stream)
- K2 stops playback
### params menu
- edit stream name
- edit stream url
- add stream (see "to add your own streams" below)

# to add your own streams:
### method one (recommended)
- direct your browser of choice to maiden (yournornsip/maiden)
- go to `/code/internet-radio/streams.txt` file
- follow the format:
`stream name`
`streamurlusuallyendingin-mp3`

### method two 
- go to the params page
- use a usb keyboard(recommended) or e2 and e3 to enter the stream info in this format:
`stream name,https://yourstreamurlusuallyendingin-mp3`

# to-do
- [ ] way to favorite streams / bump to top of list
- [ ] delete option in params
- [ ] more diverse default streams
- [ ] add default exit parameter option (close - kill mpv on new script load, or open - allow to keep playing and use as input for other scripts)
- [ ] volume control - depends on what I decide to do about input src vs passthough engine (see "radio as script" below)
- [x-ish] radio as script / tape input (https://llllllll.co/t/norns-ideas/17625/1332) ty @infinitedigits as always (:
    - without doing this: mpv runs as a separate process(doesn't register in norns mixer or get recorded to tape)
    - doing this means you have to use 'monitor' mix to listen to radio as an input source - but I might have a way around this.. (simple in -> out engine, or leverage softcut somehow?)
    - makes sense since radio is not an engine, but a process that you're running on device.  
- [x] modify / rename option in params
- [x] keyboard/encoder input to add streams

