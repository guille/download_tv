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
    -p, --pending                    Show list of pending downloads
        --clear-pending              Clear list of pending downloads
    -v                               Print version
    -h, --help                       Show this message

```

### MyEpisodes integration

By default, download_tv connects to your MyEpisodes.com account and fetches the list of episodes that have aired since the program was run for the last time. It then tries to find magnet links to download each of these shows, using the link grabbers available. You can see the grabbers with the --show-grabbers option. These magnet links will be executed with whatever program you have configured to handle the magnet:// files.

The -o flag can be used in order to re-download the episodes from previous days. The --dry-run option is useful to prevent download_tv from updating the date (for example, when running the application shortly after an episode airs).

**Note**: Due to API limitations, the gem won't find shows aired more than 14 days prior to the execution of the script.

The options -c and --show-config allow the user to change or view the current configuration values, respectively. These options include your myepisodes username, whether to save cookies or ask for password on each run and the list of ignored shows among other things. The configuration files are (mostly) backwards compatible. The gem will force you to change your configuration after an update if there are breaking changes in it.

The `auto` flag toggles whether all the results for each show are prompted to the user for him to choose or if the application should try to choose the download link automatically (by default, prioritizes PROPER/REPACK releases at 480p).

### Single torrent download

In order to download a single episode, use the -d flag, quoting the string when it contains spaces: *tv -d "Breaking Bad S04E01"*

Although it uses some settings and grabbers specific for TV shows, this option can also be used as a quick way to find and download any torrent.

### Multi torrent download

The -f flag can be used to read the list of episodes to download from a file. Each line of the file is interpreted as a episode to download: *tv -f /path/to/listofeps*

### Available link grabbers

With -g and --show-grabbers, the user can see what grabbers are available and choose one of these as their preferred option. By default, the application searches for torrents in TorrentAPI, ThePirateBay, EZTV and KAT, in that order, skipping to the next when one of them is down/doesn't have a torrent for said episode.

I usually publish a patch update to the gem when I detect one of them isn't working, disabling it or fixing it altogether. If a specific grabber is giving you problems, check whether you're running the latest version of the gem before opening an issue here.

### Pending shows

download_tv version 2.5.0 persists the list of shows it can't find on a given execution (when connecting to MyEpisodes, not for single show or file downloads). This list can be viewed by passing the -p flag to the tv binary. The list can be cleared with the --clear-pending option.

### License

This project is released under the terms of the MIT license. See [LICENSE.md](https://github.com/guille/download_tv/blob/master/LICENSE.md) file for details.