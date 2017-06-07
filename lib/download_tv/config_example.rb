module DownloadTV
	CONFIG = {
	 myepisodes_user: "", # MyEpisodes login username
	 auto: true, # Try to automatically select the torrents
	 subs: true, # Download subtitles (not implemented yet)
	 cookie_path: "cookie", # Leave blank to prevent the app from storing cookies
	 ignored: [], # list of strings that match show names as written in myepisodes
	 tpb_proxy: "https://pirateproxy.cc", # URL of the TPB proxy to use
	 grabbers: ["Eztv", "ThePirateBay", "TorrentAPI"], # names of the classes in /grabbers
	}
	
end