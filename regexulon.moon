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
	c1,c2,c3 = string.match(str, "(.-)([^\\]-([^%.]+))$")
	return "." .. c3

local dir_list, dir_listing
dir_listing = (path, file) ->
	f = path .. '/' .. file
	attr = lfs.attributes(f).mode
	{file, attr, if attr == 'directory' then dir_list(f)}

dir_list = (path) ->
	[dir_listing(path, file) for file in lfs.dir(path) when not contains({'.', '..'}, file)]

print_listing = (filedata, regex) ->
	for k, {file, mode, data} in pairs filedata
		print file, mode
		print_listing(data, regex) if data

process_files = (filedata, regex, parent) ->
	ret = {}
	parent = parent or {'',''}
	for k, {file, mode, data} in pairs filedata
		return if not rex.match(file, regex)
		if mode == 'directory'
			f = rex.match(file, regex)
			f = f\gsub('[^aA-zZ|\\d| ]', '')
			f = f\match("^%s*(.-)%s*$")
			f = target .. '/' .. f
			lfs.mkdir(f)
			parent = {inputdir .. '/' .. file, f}
		else
			ext = file_ext(file)
			newer_f = rex.match(file, regex)
			new_f = rex.match(newer_f, [[(.*)(v\d)]]) or newer_f
			new_f = new_f\gsub('[-,_, ]', '')
			new_f = rex.gsub(new_f, [[(\D*)(\d*)]], [[%1_ep%2]], 1)
			old_f, new_f = parent[1] .. '/' .. file, parent[2] .. '/' .. new_f .. ext
			lfs.link(old_f, new_f)
			print "Link: " .. old_f .. " to: " .. new_f
		item = {rex.match(file, regex), mode, data}
		item[3] = process_files(data, regex, parent) if data
		insert(ret, item)
	ret

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

regex = [==[(?:(?:\[[^\]]*\])|(?:\([^\)]*\)]))?([^\[|\]|\(|\)]*[^\[|\]|\(|\)])?]==]

processed = process_files(files, regex)
print_listing(processed)

-- ([\[]*[^\]]*[\]]*)([^\[|\]|\(|\)]*)([\[]*[^\]]*[\]]*c)
-- (?![^\[|\]*])?([^\[|\]|\(|\)]+\b)(?:[^\[|\]]*)?
-- ([\[][^\]]+[\]])+([^\[|\]|\(|\)]*)?([\[][^\]]+[\]])+
-- ([\[][^\]]*[\]])+([^\[|\]|\(|\)]*)?(([\[][^\]]+[\]])|([\(][^\)]*[\)]))+
-- ((\[[^\]]*\])|(\([^\)]*\)]))+([^\[|\]|\(|\)]*[^\[|\]|\(|\)])?
-- (?:(?:\[[^\]]*\])|(?:\([^\)]*\)]))+([^\[|\]|\(|\)]*[^\[|\]|\(|\)])?
