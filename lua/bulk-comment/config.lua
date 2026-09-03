--- @class LanguageConfig
--- @field line_comment string|nil
--- @field block_comment table|nil

--- @alias SymbolMap table<string, LanguageConfig>
--- @type SymbolMap
local symbolMap = {
	bash = {
		line_comment = "# ",
		block_comment = nil,
	},
	c = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	cs = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	css = {
		line_comment = nil,
		block_comment = { "/*", "*/" },
	},
	cpp = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	dart = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	dockerfile = {
		line_comment = "# ",
		block_comment = nil,
	},
	elixir = {
		line_comment = "# ",
		block_comment = nil,
	},
	fish = {
		line_comment = "# ",
		block_comment = nil,
	},
	go = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	html = {
		line_comment = nil,
		block_comment = { "<!--", "-->" },
	},
	htmldjango = {
		line_comment = nil,
		block_comment = { "<!--", "-->" },
	},
	java = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	javascript = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	javascriptreact = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	kdl = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	kotlin = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	lisp = {
		line_comment = "; ",
		block_comment = nil,
	},
	lua = {
		line_comment = "-- ",
		block_comment = { "--[[", "]]" },
	},
	matlab = {
		line_comment = "% ",
		block_comment = { "%{", "}%" },
	},
	perl = {
		line_comment = "# ",
		block_comment = nil,
	},
	php = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	ps1 = {
		line_comment = "# ",
		block_comment = nil,
	},
	python = {
		line_comment = "# ",
		block_comment = nil,
	},
	ruby = {
		line_comment = "# ",
		block_comment = nil,
	},
	rust = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	scala = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	sh = {
		line_comment = "# ",
		block_comment = nil,
	},
	sql = {
		line_comment = "-- ",
		block_comment = { "/*", "*/" },
	},
	swift = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	typescript = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	typescriptreact = {
		line_comment = "// ",
		block_comment = { "/*", "*/" },
	},
	vim = {
		line_comment = '" ',
		block_comment = nil,
	},
	xml = {
		line_comment = nil,
		block_comment = { "<!--", "-->" },
	},
	yaml = {
		line_comment = "# ",
		block_comment = nil,
	},
	zsh = {
		line_comment = "# ",
		block_comment = nil,
	},
}

return symbolMap
