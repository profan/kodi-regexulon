bktree = require "bk-tree"
rex = require "rex_pcre"
cli = require "cliargs"
xml = require "xml"
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
		when "mkdir"
			lfs.mkdir(new) if not debug
			"[mkdir]: #{old} to: #{new}"
		when "symlink", "hardlink"
			lfs.link(old, new, action == "hardlink" or false) if not debug
			"[link]: #{old} to: #{new}"
		else
			"unknown action: #{action}"

prompt_for_alternatives = (names, original) ->

	if not names or #names == 0	
		print "-- no results for #{original}, skipping -- " 
		return original

	print "----------------------------"
	print "Original String: #{original}"
	for i, word in pairs names
		print "##{i} #{word.str}"
	
	io.stdout\write("Enter number to pick (blank to keep original): ")
	n = io.stdin\read()

	return if tonumber(n) then names[tonumber(n)].str else original

find_alt_names = (tree, name, max_dist) ->

	io.stdout\write("Skip: #{name}? (Y/N): ")
	if io.stdin\read() == "Y" 
		io.stdin\flush()
		return {}
	max_dist = (max_dist > 0 and max_dist) or (max_dist < 0 and #name) or 100
	
	i = 0
	result = {}
	while #result == 0 and i < max_dist
		result = tree\query_sorted(name, i)
		i = i + 1

	[result[i] for i=1, #result when result[i].distance > 0]

process_xml = (string) ->
	shows = {}
	xtable = xml.load(string)

	if not xtable.xml == "anime-list" then error "incorrect XML"
	for k, t in pairs xtable
		if type(t) == "table"
			if t.xml == "anime" then
				for k2, st in pairs t
					if st.xml == "name"
						shows[#shows+1] = st[1] if type(st[1]) == "string"
						print shows[#shows]

	shows

process_files = (filedata, regex, parent) ->
	for k, {file, mode, data} in pairs filedata
		
		if rex.gsub(file, regex, '')

			isdir = (md) -> md == 'directory'

			dir_transform = (f) ->
				f = rex.gsub(f, regex, '')
				f = f\gsub('[_]', ' ')
				f = f\match("^%s*(.-)%s*$")
				altf = prompt_for_alternatives(find_alt_names(search_tree, f, maxdist), f) if parent.in == inputdir
				f = altf or f
				parent.out .. '/' .. f
				
			file_transform = (f) ->
				f = rex.gsub(f, regex, '')
				f = rex.match(f, [[(.*)(v\d)]]) or f
				f = f\gsub('[ ]', '')
				f = rex.gsub(f, [[([^\d]*)(\d+)[^\d]*$]], [[%1_ep%2]], 1)
				f ..= file_ext(file)
				parent.out .. '/' .. f

			in_f = parent.in .. '/' .. file
			out_f = if isdir(mode) then dir_transform(file) else file_transform(file)
			
			action = if isdir(mode) then "mkdir" else args["a"]
			perform_action(in_f, out_f, action)
			process_files(data, regex, {in: in_f, out: out_f}) if data

		else
			print "ERR: ", file, mode

cli\set_name("regexulon.lua")
cli\add_argument("DIR", "directory to scan")
cli\add_argument("TARGET", "target directory")
cli\optarg("IGNORED", "ignored files/directories", "")
cli\add_option("-a, --action=ACTION", "action to take: cp, mv, symlink, hardlink", "hardlink")
cli\add_flag("-n, --noprompt", "don't prompt when asking for new directory names, pick closest option.")
cli\add_flag("-e, --existing", "skip creating previously existing target directories.")
cli\add_flag("-d, --debug", "script will simulate execution.")
cli\add_flag("-V, --version", "prints the program version")
cli\add_flag("-v, --verbose", "verbose output")

export args = cli\parse_args()
return if not args

af = io.open("anime-list-full.xml", "r")
results = process_xml(af\read("*all"))

export search_tree = bktree\new()
{search_tree\insert(x) for k, x in pairs results}

io.stdout\write("Similarity Search Max Distance: ")
export maxdist = tonumber(io.stdin\read())


ignored_files = switch type(args["IGNORED"])
	when "string" then {} 
	else args["IGNORED"]

export inputdir = args["DIR"]
export targetdir = args["TARGET"]
export debug = args["d"]

files = dir_list(args["DIR"])
regex = [==[\(.*?\)|\[.*?\]]==]

processed = process_files(files, regex, {in: inputdir, out: targetdir})
