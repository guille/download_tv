# daily-shows

Modify the config_example.rb file and rename it to config.rb

Run the binary ./bin/run to pull the last episodes. If you want to repeat a past day, you can set an offset (./bin/run <offset>) that will start pulling episodes from that many days ago.

Another binary is provided (./bin/dl). Passing a show name and episode as a parameter, it tries to download it. Example: *dl The Big Bang Theory S08E01*

###TODO

* Add a value to the configuration file (:new) and if set to true, make a quick tool to set up the preferences from within the app.
* Subtitle support
* When the downloader can't find a torrent, save the show in a file and try again next execution
* Torrent grabbers: torrentz2.eu, torrentproject.se
