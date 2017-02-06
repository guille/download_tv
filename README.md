# daily-shows

daily-shows is a Ruby command line application that automatically downloads the new episodes from the shows you follow. It grabs the list of shows from your MyEpisodes account.

### Installation

Clone the repository.

Modify the config_example.rb file and rename it to config.rb

### Usage

Three binaries are provided:

* /bin/run: Fetches the list of episodes from MyEpisodes and tries to download all the new episodes since the last time the program was run. This binary accepts an offset as a parameter in order to re-download the episodes from previous days.

* /bin/dl: This binary accepts a show name and episode as a parameter, and will try to download said episode. Example: *dl Breaking Bad S04E01*

* /bin/fromfile: Takes a text file as an argument. Each line of the file is interpreted as a episode to download. Example: *dl /path/to/listofeps*