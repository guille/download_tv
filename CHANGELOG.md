# download_tv CHANGELOG

## 2.6.9 (2023-03-08)

* Fixes
	* Bug fixes on the TorrentAPI grabber.

## 2.6.8 (2022-12-02)

* Improvements
	* Improvements on the TorrentAPI grabber.
	* Better detection of grabbers being offline.

## 2.6.7 (2022-10-22)

* Features
	* Add `--healthcheck` to check the status of all the grabbers (online/offline).

* Fixes
	* Better detection for offline grabbers without crashing the app

* Grabbers
	* Torrentz: Fix parser

## 2.6.6 (2022-01-21)

* Improvements
	* The `--dry-run` option now prevents from persisting any configuration, including pending shows, not just the last execution date.
	* Performance improvements when running with the `-t` flag.

## 2.6.5 (2021-06-10)

* Fixes
	* Bump HTTP read timeout to avoid errors on new grabber.

## 2.6.4 (2021-06-07)

* Grabbers
	* Torrentz: added Torrentz2 grabber.

## 2.6.3 (2021-05-24)

* Fixes
	* Fix download full season feature (`-s/--season`), inadvertently broken in 2.6.2.

## 2.6.2 (2021-05-20)

* Fixes
	* Avoid duplicate downloads when using `-t` and `-o` together.

* Improvements
	* Add `-s` shorthand to the `--season` flag.

## 2.6.1 (2020-09-22)

* Features
	* Add `-q/--queue` to manually add an episode to the pending list.

* Improvements
	* Gracefully exits after option parsing errors.

* Grabbers
	* EZTV: now sorts torrents by number of seeders.
	* ThePirateBay: disable grabber.

## 2.5.5 (2019-04-06)

* Features
	* Allow user to configure include/exclude filters of the results.

* Improvements
	* The `-t/--tomorrow` flag now also performs a normal run if needed.

## 2.5.4 (2019-01-19)

* Features
	* Add `--season` to try and sequentially download all episodes of the given show, for the given season.
	* Add `-t/--tomorrow` to download the shows airing in the current day.

## 2.5.3 (2018-12-14)

* Fixes
	* Fix bug preventing clearing pending shows from working properly.

## 2.5.2 (2018-12-10)

* Fixes
	* Changing the configuration no longer resets the list of pending downloads.

## 2.5.1 (2018-12-03)

* Fixes
	* Fix pending shows handling.

## 2.5.0 (2018-12-02)

* Fixes
	* Fix not detecting successful MyEpisodes login.
	* Fix not detecting non-backwards compatible version changes.
	* Fix names not being sanitised when downloading through `-d/--download`
	* Fix names not being sanitised when downloading through `-f/--file`

* Features
	* Persist list of episodes not found in the configuration.
	* Add `-p/--pending` to show the list of pending downloads.
	* Add `--clear-pending` to empty the list of pending downloads.

* Grabbers
	* KAT: disable grabber.

## 2.4.7 (2018-10-05)

* Grabbers
	* KAT: re-enable grabber, updating rules for new CSS structure.

## 2.4.6 (2018-07-19)

* Grabbers
	* KAT: disable grabber.

## 2.4.5 (2018-05-04)

* Grabbers
	* TorrentAPI: now sorts by seeders.

## 2.4.4 (2018-03-22)

* Grabbers
	* TorrentAPI: fix timeouts.

## 2.4.3 (2018-03-22)

* Fixes
	* Fix new trackers' availability not being checked before attempting to use them.

## 2.4.2 (2018-03-14)

* Fixes
	* Fix bug where the wrong grabber was being removed when offline.

## 2.4.1 (2018-03-12)

* Fixes
	* Fix bug accessing wrong variable when a grabber was offline.

## 2.4.0 (2018-03-04)

* Fixes
	* Fix not reporting "Nothing to download" when it was due to ignored shows.
	* Fix downloading from file not handling newlines well.

* Improvements
	* Reset grabber order after every download.

* Grabbers
	* KAT: fix parsing rules.
	* ThePirateBay: change proxy URL.

## 2.3.0 (2017-09-24)

* Improvements
	* Store configuration file as JSON instead of Marshaling the hash.
	* Use custom User-Agent for all connections.

* Grabbers
	* ThePirateBay: change proxy URL.

## 2.2.2 (2017-08-06)

* Fixes
	* Fix date not being saved in the configuration.

## 2.2.1 (2017-08-03)

* Add LICENSE.md to repo

* Fixes
	* Fix default grabber not being properly selected.

* Improvements
	* Add support for OS X.

* Grabbers
	* TorrentAPI: add temporary workaround for CloudFlare errors.

## 2.2.0 (2017-08-01)

* Add LICENSE information to Gemfile
* Move default path to configuration file to `~/.config/download_tv/config`

* Improvements
	* Improve detection of ignored shows.

## 2.1.1 (2017-07-31)

* Improvements
	* Minor improvements to configuration file handling.

## 2.1.0 (2017-07-21)

* Features
	* Add `-g/--grabber` to select which grabber to use for finding links.
	* Add `--show-grabbers` to list available options.
	* Add `-v` to print gem version.

* Grabbers
	* KAT: added KickAssTorrents grabber.

## 2.0.6 (2017-07-11)

* Improvements
	* Remove colons from the show name for searching.

## 2.0.5 (2017-06-17)

* Features
	* Add `--show-config` to print contents of the configuration file in a readable way.

* Fixes
	* Fix download from file not properly finding the path.

## 2.0.3 (2017-06-07)

* Fixes
	* Fix missing arguments breaking the main entrypoint.
	* Fix ignored shows list not handling multiple comma-separated shows.
	* Minor fixes on configuration file.

## 2.0.0 (2017-06-07)

* Features
	* Add new configuration system.

## 1.0.0 (2017-06-07)

Initial published version.
