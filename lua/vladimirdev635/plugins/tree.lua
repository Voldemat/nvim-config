return {
    {
        "nvim-tree/nvim-tree.lua",
        version = "v1.13.0",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup {
                view = {
                    width = 40
                },
                sort = { sorter = "case_sensitive" },
                filters = { dotfiles = false }
            }
            vim.keymap.set('n', '<leader>tf', ':NvimTreeFindFile<cr>', {})
            vim.keymap.set('n', '<leader>tc', ':NvimTreeClose<cr>', {})
            vim.keymap.set('n', '<leader>ta', ':NvimTreeOpen<cr>', {})
        end
    }
}
