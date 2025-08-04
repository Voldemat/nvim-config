return {
    {
        "nvim-treesitter/nvim-treesitter",
        tag = 'v0.10.0',
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require 'nvim-treesitter.configs'.setup {
                ensure_installed = {
                    "ada",
                    "c",
                    "lua",
                    "vim",
                    "vimdoc",
                    "javascript",
                    "html",
                    "css",
                    "typescript",
                    "python",
                    "hcl",
                    "terraform",
                    "vue",
                    "go",
                    "helm",
                    "gotmpl",
                    "bash",
                    "graphql"
                },
                highlight = { enable = true },
                indent = { enable = true },
            }
        end
    }
}
