# download_tv

[![Build Status](https://travis-ci.org/guille/daily-shows.svg?branch=master)](https://travis-ci.org/guille/daily-shows)

download_tv is a Ruby command line application that automatically downloads the new episodes from the shows you follow. It grabs the list of shows from your MyEpisodes account.

### Installation

Clone the repository.

Rename the config_example.rb to config.rb and modify it if needed.

### Usage

A binary is provided in /bin/tv.

```
Usage: tv [options]

Specific options:
    -o, --offset OFFSET              Move back the last run offset
    -f, --file PATH                  Download shows from a file
    -d, --download SHOW              Downloads given show
        --dry-run                    Don't write to the date file
    -h, --help                       Show this message
```

Three actions are recognised:

* By default, it fetches the list of episodes from MyEpisodes that have aired since the program was run for the last time and tries to download them. The -o flag can be used in order to re-download the episodes from previous days.

* In order to download a single episode, use the -d flag. Example: *tv -d Breaking Bad S04E01*

* Finally, the -f flag can be used to download a set of episodes. This option takes a text file as an argument. Each line of the file is interpreted as a episode to download. Example: *tv -f /path/to/listofeps*

### Configuration

* myepisodes_user: String containing the username that will be used to log in to MyEpisodes. Set to an empty string to have the application ask for it in each execution.

* auto: Boolean value (true/false). Determines whether the application will try to automatically select a torrent using pre-determined filters or show the list to the user and let him choose.

* subs: Not implemented yet. Boolean value (true/false). Determines whether the application will try to find subtitles for the shows being downloaded.

* cookie_path: String containing a path to where the session cookie for MyEpisodes will be stored. Set it to "" to prevent the cookie from being stored.

* ignored: Array containing names of TV shows you follow in MyEpisodes but don't want to download. The strings should match the name of the show as displayed by MyEpisodes. Example: ["Boring Show 1", "Boring Show 2"],

* tpb_proxy: Base URL of the ThePirateBay proxy to use.

* grabbers: String containing names of the sources where to look for torrents in ascending order of preference. Useful for activating or deactivating specific sites, reordering them or for plugin developers.