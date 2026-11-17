return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        branch = "main",
        config = function()
            require('nvim-treesitter').setup({
                install_dir = vim.fn.stdpath('data') .. '/site',
            })
            require('nvim-treesitter').install(
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
                "rust",
                "vrl",
                "toml",
                "selinux"
            )
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("tree-sitter-enable", { clear = true }),
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(args.match)
                    if not lang or not vim.treesitter.language.add(lang) or lang == "toml" then return end

                    if vim.treesitter.query.get(lang, "highlights") then vim.treesitter.start(args.buf) end
                end,
            })
        end
    }
}
