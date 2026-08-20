---@class SymbolMap
---@field double_slash LanguageConfig
---@field hash LanguageConfig
---@field double_dash LanguageConfig

---@class LanguageConfig
---@field symbol string
---@field languages string[]

---@type SymbolMap
local revisedMap = {
    double_slash = {
        symbol = "// ",
        languages = {
            "c",
            "go",
            "kdl",
            "javascrip",
            "javascriptreact",
            "typescript",
            "typescriptreact"
        }
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
            "dockerfile"
        }
    },
    double_dash = {
        symbol = "-- ",
        languages = {
            "lua",
            "sql",
        }
    },
}

return revisedMap
