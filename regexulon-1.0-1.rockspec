package = "regexulon"
version = "1.0-1"
source = {
	url = "..."
}

description = {
	summary = "thingy",
	detailed = [[
		detailed thingy
	]],
	homepage = "http://..",
	license = "MIT/X11"
}

dependencies = {
	"lua >= 5.1",
	"luafilesystem",
	"lua_cliargs >= 2.0"
}

build = {
	type = "make"
}
