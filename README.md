regexulon
=================================

Utility made to reorganize media library of disorganized files into a collection which XBMC/Kodi's TVDB parser can read and make a library out of.

Lets you either move and rename the files, copy and rename, or accomplish it with symlinks/hardlinks.

Still needs a lot of work to be of use to anyone.

## Usage Area
Created for absolutely ordered episodes, already in their correct subfolders, attempts to filter out most of the noise which normally prevents the various scrapers from parsing the information.

Currently catches cases where a show folder is named like `[stuff](things) show name (otherstuff)[woo]` with episodes inside which are similar, the last number in the filename is treated as the episode number and appended with `ep` to help the scraper.

Also uses a [bk-tree](https://github.com/profan/lua-bk-tree) loaded with information from a [list](https://raw.github.com/ScudLee/anime-lists/master/anime-list-full.xml) of names to match episodes towards the list of names, currently only handles anime, but intended to become more generic.

## Example

	//Example run: ./regexulon --debug testdata target
	Similarity Search Max Distance: -1 (-1 to set the max edit distance to length of string)
	Skip: Show Name Folder? (Y/N): N 
	----------------------------
	Original String: Show Name Folder 
	#1 Votoms Finder 
	#2 Rhea Gall Force 
	Enter number to pick (blank to keep original):
	//listed by closest match, in this case it's contrived since it's a fake name.
	//picking a number would make the target folder name the name of the number picked


Requirements
------------

* Lua >= 5.1
* LuaRocks (not required, but makes it easier to get the dependencies)
* MoonScript
* LuaFileSystem
* lua\_cliargs
* bk-tree


Downloading the source
------------
Either with git clone as below or by downloading a zipball of the [latest...](https://github.com/profan/kodi-regexulon/archive/master.zip)
		
	git clone https://github.com/profan/kodi-regexulon.git

Building
------------

	luarocks make rockspecs/regexulon-1.0-1.rockspec

Usage
------------

	Usage: regexulon [OPTIONS]  DIR  TARGET  [IGNORED]
	
	ARGUMENTS: 
	  DIR                 directory to scan (required)
	  TARGET              target directory (required)
	  IGNORED             ignored files/directories (optional, default: )
	
	OPTIONS: 
	  -a, --action=ACTION action to take: cp, mv, symlink, hardlink
	                      (default: hardlink)
	  -n, --noprompt      don't prompt when asking for new directory names,
	                      pick closest option.
	  -e, --existing      skip creating previously existing target
	                      directories.
	  -d, --debug         script will simulate execution.
	  -V, --version       prints the program version
	  -v, --verbose       verbose output


TODO
------------

 - [ ] ... write tests?

Credits
------------

	...

License
------------
See attached LICENSE file.

