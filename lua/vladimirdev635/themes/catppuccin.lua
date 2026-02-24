return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        opts = {
            custom_highlights = function(colors)
                return {
                    ["@module"] = { fg = colors.lavender },
                    ["@property"] = { fg = colors.lavender },
                    ["@variable.member"] = { fg = colors.lavender },
                    ["@type.builtin"] = { fg = colors.yellow },
                    ["@constructor.typescript"] = { fg = colors.blue }
                }
            end,
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                treesitter = true,
            }
        }
    }
}
