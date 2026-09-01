return {
    {
        'nvim-telescope/telescope.nvim',
        tag = 'v0.2.1',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-media-files.nvim' },
        opts = {
            extensions = {
                media_files = {
                    filetypes = { "png", "jpg", "mp4", "webm", "pdf", "ico" },
                    find_cmd = "rg",
                    image_stretch = 10
                }
            },
            pickers = {
                find_files = {
                    hidden = true
                }
            }
        },
        config = function(opts)
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
            vim.keymap.set('n', '<leader>flg', builtin.live_grep, { desc = 'Telescope live grep' })
            vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = 'Telescope resume' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
            vim.keymap.set('n', '<leader>fs', builtin.grep_string, { desc = 'Telescope string grep' })
            vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Telescope find git files' })
            vim.keymap.set('n', '<leader>ch', builtin.command_history, { desc = 'Command history' })
            vim.keymap.set('n', '<leader>sh', builtin.search_history, { desc = 'Telescope search history' })
            local telescope = require('telescope')
            telescope.setup(opts)
            vim.keymap.set('n', '<leader>mf', telescope.extensions.media_files.media_files)
        end
    }
}
