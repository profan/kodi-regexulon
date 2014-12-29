rex = require "rex_posix"
cli = require "cliargs"
lfs = require "lfs"

import concat, insert from table


contains = (t, item) ->
	for k, v in pairs t
		return true if item == v
	false

local dir_list, dir_listing
dir_listing = (path, file) ->
	f = path .. '/' .. file
	attr = lfs.attributes(f).mode
	{file, attr, if attr == 'directory' then dir_list(f)}

dir_list = (path) ->
	[dir_listing(path, file) for file in lfs.dir(path) when not contains({'.', '..'}, file)]

print_listing = (filedata) ->
	for k, {file, mode, data} in pairs filedata
		print file, mode
		print_listing(data) if data

cli\set_name("regnamex.lua")
cli\add_argument("DIR", "directory to scan")
cli\optarg("IGNORED", "ignored files/directories")
cli\add_flag("-t, --type", "action to take: cp, mv, symlink, defaults to symlink", "symlink")
cli\add_flag("-v, --version", "prints the program version")
cli\add_flag("-d, --debug", "script will simulate excution, print actions.")


args = cli\parse_args()
return if not args

ignored_files = switch type(args["IGNORED"])
	when "string"
		{}
	else
		args["IGNORED"]

files = dir_list(args["DIR"])
print_listing(files)


