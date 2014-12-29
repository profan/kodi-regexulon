rex = require "rex_posix"
cli = require "cliargs"
lfs = require "lfs"

import concat, insert from table

dir_listing = (path) ->
	ret = {}
	for file in lfs.dir(path)
		attr = lfs.attributes(path .. '/' .. file).mode
		item = {file, attr, if attr == 'directory' and file != '.' and file != '..' then dir_listing(path .. '/' .. file)}
		insert(ret, item) if file != '.' and file != '..'
	ret

cli\set_name("regnamex.lua")
cli\add_argument("DIR", "directory to scan")
cli\add_flag("-t, --type", "takes copy, move, symlink, defaults to symlink.")
cli\add_flag("-v, --version", "prints the program version")
cli\add_flag("-d, --debug", "script will simulate excution, print actions.")

args = cli\parse_args()
return if not args

files = dir_listing(args["DIR"])

print_listing = (filedata) ->
	for k, {file, mode, data} in pairs filedata
		print file, mode
		print_listing(data) if data

print_listing(files)
