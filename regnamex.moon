rex = require "rex_posix"
cli = require "cliargs"
lfs = require "lfs"

import concat, insert from table

local dir_list, dir_listing
dir_listing = (path, file) ->
	f = path .. '/' .. file
	attr = lfs.attributes(f).mode
	{file, attr, if attr == 'directory' then dir_list(f)}

dir_list = (path) ->
	[dir_listing(path, file) for file in lfs.dir(path) when file != '.' and file != '..']

cli\set_name("regnamex.lua")
cli\add_argument("DIR", "directory to scan")
cli\add_flag("-t, --type", "takes copy, move, symlink, defaults to symlink.")
cli\add_flag("-v, --version", "prints the program version")
cli\add_flag("-d, --debug", "script will simulate excution, print actions.")

args = cli\parse_args()
return if not args

files = dir_list(args["DIR"])

print_listing = (filedata) ->
	for k, {file, mode, data} in pairs filedata
		print file, mode
		print_listing(data) if data

print_listing(files)
