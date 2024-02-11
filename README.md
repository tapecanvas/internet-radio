# this is a work in progress!
- **requires internet connection (wifi or ethernet) and mpv to be installed (not sure if it's installed by default?)**
    - to check/install mpv:
        - ssh into norns `ssh we@norns.local`
        - run `sudo apt install mpv` 
- a great use for norns when you're not actively making music on it
- also a test of github copilot
- inspired by @mlogger 's idea in https://llllllll.co/t/norns-ideas/17625/1328

# currently
- hardcoded table of streams
- E3 scrolls through list
- K3 plays selected stream (also stops previously playing stream before playing a new stream)
- K2 stops playback

# to add your own streams:
### method one (recommended)
- direct your browser of choice to maiden (yournornsip/maiden)
- go to /code/internet-radio/streams.txt file
- follow the format:
stream name
(newline)streamurlusuallyendingin-mp3

### method two 
- go to the params page
- use a usb keyboard(recommended) or e2 and e3 to enter the stream info in this format:
stream name,https://yourstreamurlusuallyendingin-mp3

# to-do
- [ ] volume control
- [ ] radio as script / tape input (https://llllllll.co/t/norns-ideas/17625/1332) ty @infinitedigits as always (:
- [x] keyboard/encoder input to add streams
- [ ] way to favorite streams / bump to top of list
- [x] modify / rename option in params
- [ ] delete option in params
