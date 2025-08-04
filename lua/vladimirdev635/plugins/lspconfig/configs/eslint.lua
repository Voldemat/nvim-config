vim.lsp.config('eslint', {
    on_attach = function()
        vim.keymap.set('n', '<leader>ef', ':EslintFixAll<CR>', { silent = true })
    end
})
vim.lsp.enable('eslint')
