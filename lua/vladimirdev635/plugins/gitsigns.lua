vim.opt.signcolumn = "yes"
vim.keymap.set('n', '<leader>gb', ":Gitsigns blame<CR>", {
    silent = true
})
vim.keymap.set('n', '<leader>gl', ":Gitsigns toggle_current_line_blame<CR>", {
    silent = true
})
vim.keymap.set('n', '<leader>gd', ":Gitsigns diffthis HEAD<CR>", {
    silent = true
})
return {
    {
        'lewis6991/gitsigns.nvim',
        opts = {
        }
    }
}
