rex = require "rex_pcre"
cli = require "cliargs"
lfs = require "lfs"

import concat, insert from table

contains = (t, item) ->
	return true if item == nil
	for k, v in pairs t
		return true if item == v
	false

file_ext = (str) ->
	return "." .. str\match(".([^%.]+)$")

local dir_list, dir_listing
dir_listing = (path, file) ->
	f = path .. '/' .. file
	attr = lfs.attributes(f).mode
	{file, attr, if attr == 'directory' then dir_list(f)}

dir_list = (path) ->
	[dir_listing(path, file) for file in lfs.dir(path) when not contains({'.', '..'}, file)]

map_listing = (structure, func) ->
	for k, v in pairs structure
		func(v, map_listing)

print_listing = (value, func) ->
	{file, mode, data} = value
	print file, mode
	func(data, print_listing) if data

process_files = (filedata, regex, parent) ->
	for k, {file, mode, data} in pairs filedata
		if rex.gsub(file, regex, '')
			if mode == 'directory'
				f = rex.gsub(file, regex, '')\match("^%s*(.-)%s*$")
				f = parent.out .. '/' .. f
				lfs.mkdir(f)
				process_files(data, regex, {in: parent.in .. '/' .. file, out: f})
			else
				ext = file_ext(file)
				newer_f = rex.gsub(file, regex, '')
				new_f = rex.match(newer_f, [[(.*)(v\d)]]) or newer_f
				new_f = new_f\gsub('[ ]', '')
				new_f = rex.gsub(new_f, [[([^\d]*)(\d+)[^\d]*$]], [[%1_ep%2]], 1)
				old_f, new_f = parent.in .. '/' .. file, parent.out .. '/' .. new_f .. ext
				lfs.link(old_f, new_f) if not debug
				print "[D: " .. ((debug and "T") or "F") .. "] Link: " .. old_f .. " to: " .. new_f

		else
			print "ERR: ", file, mode

cli\set_name("regnamex.lua")
cli\add_argument("DIR", "directory to scan")
cli\add_argument("TARGET", "target directory")
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

export inputdir = args["DIR"]
export files = dir_list(args["DIR"])
export target = args["TARGET"]
export debug = args["d"]

regex = [==[\(.*?\)|\[.*?\]]==]

map_listing(files, print_listing)

processed = process_files(files, regex, {in: inputdir, out: target})
--print_listing(processed)
