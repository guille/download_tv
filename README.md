# download_tv

[![Build Status](https://travis-ci.org/guille/download_tv.svg?branch=master)](https://travis-ci.org/guille/download_tv)
[![Gem Version](https://badge.fury.io/rb/download_tv.svg)](https://badge.fury.io/rb/download_tv)

download_tv is a Ruby command line application that automatically downloads the new episodes from the shows you follow. It grabs the list of shows from your MyEpisodes account.

### Installation

`gem install download_tv`

### Usage

Once installed, you can launch the binary *tv*

```
Usage: tv [options]

Specific options:
    -o, --offset OFFSET              Move back the last run offset
    -f, --file PATH                  Download shows from a file
    -d, --download SHOW              Downloads given show
    -c, --configure                  Configures defaults
        --dry-run                    Don't write to the date file
    -a, --[no-]auto                  Automatically find links
    -s, --[no-]subtitles             Download subtitles
    -h, --help                       Show this message

```

Four actions are recognised:

* By default, it fetches the list of episodes from MyEpisodes that have aired since the program was run for the last time and tries to download them. The -o flag can be used in order to re-download the episodes from previous days.

* In order to download a single episode, use the -d flag. Example: *tv -d Breaking Bad S04E01*

* he -f flag can be used to download a set of episodes. This option takes a text file as an argument. Each line of the file is interpreted as a episode to download. Example: *tv -f /path/to/listofeps*

* Finally, with -c you can edit your configuration defaults (your MyEpisodes user, whether to save the auth cookie or the shows you wish to ignore)
