---@class LineSymbolMap
---@field double_slash LanguageConfig
---@field hash LanguageConfig
---@field double_dash LanguageConfig

---@class LanguageConfig
---@field symbol string
---@field languages string[]

---@type LineSymbolMap
local lineSymbols = {
	double_slash = {
		symbol = "// ",
		languages = {
			"c",
			"dart",
			"go",
			"kdl",
			"kotlin",
            "java",
			"javascrip",
			"javascriptreact",
            "php",
            "scala",
            "swift",
            "rust",
			"typescript",
			"typescriptreact",
		},
	},
	hash = {
		symbol = "# ",
		languages = {
			"python",
			"bash",
			"sh",
			"zsh",
			"fish",
			"ps1",
			"perl",
			"yaml",
			"dockerfile",
		},
	},
	double_dash = {
		symbol = "-- ",
		languages = {
			"lua",
			"sql",
		},
	},
}

local blockSymbols = {
	hash = {
		symbol = "# ",
		languages = {
			"python",
			"bash",
			"sh",
			"zsh",
			"fish",
			"ps1",
			"perl",
			"yaml",
			"dockerfile",
		},
	},
    dash_star = {
		symbol = {"/* ", " */"},
	    languages = {
			"c",
			"dart",
			"go",
			"kdl",
			"kotlin",
            "java",
			"javascrip",
			"javascriptreact",
            "php",
            "scala",
            "swift",
            "sql",
            "rust",
			"typescript",
			"typescriptreact",
		},

    }
}

return lineSymbols
