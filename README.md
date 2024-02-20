# download_tv

[![Ruby](https://github.com/guille/download_tv/actions/workflows/ruby.yml/badge.svg?branch=master)](https://github.com/guille/download_tv/actions/workflows/ruby.yml)
[![Gem Version](https://badge.fury.io/rb/download_tv.svg)](https://badge.fury.io/rb/download_tv)
[![Code Climate](https://codeclimate.com/github/guille/download_tv.svg)](https://codeclimate.com/github/guille/download_tv)

**download_tv** is a tool that allows the user to find magnet links for TV show episodes. It accepts shows as arguments, from a file or it can integrate with your MyEpisodes account.

## Installation

`gem install download_tv`

## Usage

Once installed, you can launch the binary `tv`

```
Usage: tv [options]

Specific options:
    -o, --offset OFFSET              Move back the last run offset
    -f, --file PATH                  Download shows from a file
    -d, --download SHOW              Downloads given show
    -s, --season SEASON              Limit the show download to a specific season
    -t, --tomorrow                   Download shows airing today
    -c, --configure                  Configures defaults
        --show-config                Show current configuration values
        --dry-run                    Don't write to the date file
    -a, --[no-]auto                  Automatically find links
    -g, --grabber GRABBER            Use given grabber as first option
        --show-grabbers              List available grabbers
        --healthcheck                Check status of all the grabbers
    -p, --pending                    Show list of pending downloads
        --clear-pending              Clear list of pending downloads
    -q, --queue SHOW                 Add show episode to pending downloads list
    -v, --version                    Print version
    -h, --help                       Show this message
```

### MyEpisodes integration

By default, **download_tv** connects to your [MyEpisodes.com](https://www.myepisodes.com/) account and fetches the list of episodes that have aired since the program was run for the last time. It then tries to find magnet links to download each of these shows, using the link grabbers available. You can see the grabbers with the `--show-grabbers` option. These magnet links will be executed with whatever program you have configured to handle magnet:// files.

The `-o` flag can be used in order to re-download the episodes from previous days. The `--dry-run` option is useful to prevent **download_tv** from updating the date (for example, when running the application shortly after an episode airs).

The application also includes the `-t/--tomorrow` flag. By default, an execution of **download_tv** will download shows airing from the last execution of the program up to a day prior to the current day. This flag can be used to include in the search the episodes airing in the same day. This can be useful depending on your timezone or on the airtime of the shows you follow.

**Note**: Due to API limitations, the gem won't find shows aired more than 14 days prior to the execution of the script.

The options `-c` and `--show-config` allow the user to change or view the current configuration values, respectively. These options include your MyEpisodes username, whether to save cookies or ask for password on each run and the list of ignored shows among other things. The gem (mostly) follows semver to track configuration file changes. It will automatically trigger a configuration update when it detects an older non-compatible version.

The `--auto` flag toggles whether all the results for each show are prompted to the user for him to choose or if the application should try to choose the download link automatically (see Section Filters). By default, all grabbers try to sort by number of seeders.

### Single torrent download

In order to download a single episode, use the `-d` flag, quoting the string when it contains spaces:

```
tv -d "Breaking Bad S04E01"
```

Although it uses some settings and grabbers specific for TV shows, this option can also be used as a quick way to find and download any torrent.

It can be optionally used in conjunction with the `--season` flag to try to find and download a whole season of the given show: `tv -d "Breaking Bad" --season 4`. It will start searching from episode 1 and continue upwards until it can't find any torrent for an episode.

### Multi torrent download

The `-f` flag can be used to read the list of episodes to download from a file. Each line of the file is interpreted as a episode to download.

### Available link grabbers

With `-g` and `--show-grabbers`, the user can see what grabbers are available and choose one of these as their preferred option. By default, the application searches for torrents using Torrentz. When a grabber doesn't have a torrent for said episode, is offline, or causes any error to appear, it skips to the next grabber until exhausting the list.

I usually publish a patch update to the gem when I detect one of them isn't working, disabling it or fixing it altogether. If a specific grabber is giving you problems, check whether you're running the latest version of the gem before opening an issue here.

### Pending shows

**download_tv** persists the list of shows it can't find on a given execution (when connecting to MyEpisodes, not for single show or file downloads) and it will try to find them again on following executions. This list can be viewed by passing the -p flag to the tv binary. The list can be cleared with the --clear-pending option.

It also has the functionality to queue an episode by running `tv --queue "show name"`. The --queue parameter cannot be used in conjunction with any other parameters.

### Filters

**download_tv** allows setting include/exclude filters for the automatic download of shows.

Upon installation, the default filters exclude 2060p, 1080p or 720p, and include PROPER or REPACK releases when available. The user can specify in their configuration (`tv -c`) a list of words to include or exclude from their results that will override these defaults.

Keep in mind that this is not a hard filter. The application will sequentially apply as many user-defined filters as possible **while still returning at least one result**.

## Shell completion

The provided binary will print completion files to STDOUT by passing the options `--*-completion-bash` and `--*-completion-zsh` (you might have to escape the asterisk). Use your shell's manual to find out how to load these files to get completions.

## License

This project is released under the terms of the MIT license. See [LICENSE.md](https://github.com/guille/download_tv/blob/master/LICENSE.md) file for details.
