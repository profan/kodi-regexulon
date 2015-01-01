regexulon
=================================

Utility made to reorganize media library of disorganized files into a collection which XBMC/Kodi's TVDB parser can read and make a library out of.

Lets you either move and rename the files, copy and rename, or accomplish it with symlinks/hardlinks.
Keeps track of created shows in a textfile to allow deletion if requested.

Created for absolutely ordered episodes, already in their correct subfolders, attempts to filter out most of the noise which normally prevents the various scrapers from parsing the information.

Currently catches cases where a show folder is named like `[stuff](things) show name (otherstuff)[woo]` with episodes inside which are similar, the last number in the filename is treated as the episode number and appended with `ep` to help the scraper.


Requirements
------------

* MoonScript
* LuaFileSystem
* lua\_cliargs


Downloading the source
------------
Either with git clone as below or by downloading a zipball of the [latest...]()
		
	...

Usage
------------

	...

TODO
------------

 - [ ] ... write tests?

Credits
------------

	...

License
------------
See attached LICENSE file.

