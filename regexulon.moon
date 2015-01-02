rex = require "rex_pcre"
cli = require "cliargs"
lfs = require "lfs"

import insert from table

contains = (t, item) ->
	for k, v in pairs t
		return true if v == item
	false

local dir_list, dir_listing
dir_listing = (path, file) ->
	f = path .. '/' .. file
	attr = lfs.attributes(f).mode
	{file, attr, if attr == 'directory' then dir_list(f)}

dir_list = (path) ->
	[dir_listing(path, file) for file in lfs.dir(path) when not contains({'.', '..'}, file)]

map_listing = (structure, func) ->
	results = {}
	for k, v in pairs structure
		res = func(v, map_listing)
		insert(results, res) if res
	results

print_listing = (value, func) ->
	{file, mode, data} = value
	print file, mode
	func(data, print_listing) if data

file_ext = (str) ->
	"." .. str\match(".([^%.]+)$")

dbg = (b) -> 
	"[DBG: #{(b and 'Y') or 'N'}]"

perform_action = (old, new, action) ->
	dbg(debug) .. switch action
		when "copy"
			"[cp]: Not yet implemented."
		when "move"
			"[mv]: Not yet implemented."
		when "symlink", "hardlink"
			lfs.link(old, new, action == "hardlink" or false) if not debug
			"[link]: #{old} to: #{new}"
		else
			"unknown action: #{action}"

process_files = (filedata, regex, parent) ->
	for k, {file, mode, data} in pairs filedata
		if rex.gsub(file, regex, '')
			if mode == 'directory'
				in_f = parent.in .. '/' .. file
				out_f = do
					f = file
					->
					f = rex.gsub(f, regex, '')
					f = f\match("^%s*(.-)%s*$")
					parent.out .. '/' .. f
				lfs.mkdir(out_f)
				process_files(data, regex, {in: in_f, out: out_f})
			else
				ext = file_ext(file)
				newer_f = rex.gsub(file, regex, '')
				new_f = rex.match(newer_f, [[(.*)(v\d)]]) or newer_f
				new_f = new_f\gsub('[ ]', '')
				new_f = rex.gsub(new_f, [[([^\d]*)(\d+)[^\d]*$]], [[%1_ep%2]], 1)
				old_f, new_f = parent.in .. '/' .. file, parent.out .. '/' .. new_f .. ext
				print perform_action(old_f, new_f, args["a"])

		else
			print "ERR: ", file, mode

cli\set_name("regexulon.lua")
cli\add_argument("DIR", "directory to scan")
cli\add_argument("TARGET", "target directory")
cli\optarg("IGNORED", "ignored files/directories", "")
cli\add_option("-a, --action=ACTION", "action to take: cp, mv, symlink, hardlink", "hardlink")
cli\add_flag("-e, --existing", "skip creating previously existing target directories.")
cli\add_flag("-d, --debug", "script will simulate execution.")
cli\add_flag("-V, --version", "prints the program version")
cli\add_flag("-v, --verbose", "verbose output")

export args = cli\parse_args()
return if not args

ignored_files = switch type(args["IGNORED"])
	when "string" then {} 
	else args["IGNORED"]

inputdir = args["DIR"]
targetdir = args["TARGET"]
export debug = args["d"]

files = dir_list(args["DIR"])
regex = [==[\(.*?\)|\[.*?\]]==]

--map_listing(files, print_listing)
processed = process_files(files, regex, {in: inputdir, out: targetdir})
