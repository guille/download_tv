# download_tv

[![Build Status](https://travis-ci.org/guille/download_tv.svg?branch=master)](https://travis-ci.org/guille/download_tv)
[![Gem Version](https://badge.fury.io/rb/download_tv.svg)](https://badge.fury.io/rb/download_tv)
[![Code Climate](https://codeclimate.com/github/guille/download_tv.svg)](https://codeclimate.com/github/guille/download_tv)

download_tv is a tool that allows the user to find magnet links for TV show episodes. It accepts shows as arguments, from a file or it can integrate with your MyEpisodes account.

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
        --show-config                Show current configuration values
        --dry-run                    Don't write to the date file
    -a, --[no-]auto                  Automatically find links
    -s, --[no-]subtitles             Download subtitles
    -g, --grabber GRABBER            Use given grabber as first option
        --show-grabbers              List available grabbers
    -v                               Print version
    -h, --help                       Show this message

```

### Examples

By default, it fetches the list of episodes from MyEpisodes.com that have aired since the program was run for the last time and tries to download them. The -o flag can be used in order to re-download the episodes from previous days. The --dry-run option is useful to prevent download_tv from updating the date (for example, when running the application shortly after an episode airs)

In order to download a single episode, use the -d flag, quoting the string when it contains spaces: *tv -d "Breaking Bad S04E01"*

The -f flag can be used to read the list of episodes to download from a file. Each line of the file is interpreted as a episode to download: *tv -f /path/to/listofeps*

The options -c and --show-config allow the user to change or view the current configuration values, respectively. These options include your myepisodes username, whether to save cookies or ask for password on each run and the list of ignored shows.

The `auto` flag toggles whether all the results for each show are prompted to the user for him to choose or if the application should try to choose the download link automatically (by default, prioritizes PROPER/REPACK releases at 480p).

With -g and --show-grabbers, the user can see what grabbers are available and choose one of these as their preferred option. By default, the application searchs for torrents in TorrentAPI, ThePirateBay, KAT and EZTV, in that order, skipping to the next when one of them is down/doesn't have a torrent for said episode.

### License

This project is released under the terms of the MIT license. See [LICENSE.md](https://github.com/guille/download_tv/blob/master/LICENSE.md) file for details.