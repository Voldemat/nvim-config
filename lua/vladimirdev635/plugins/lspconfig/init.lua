vim.keymap.set('n', ']g', function()
    vim.diagnostic.jump({ count = 1 })
end)
vim.keymap.set('n', '[g', function()
    vim.diagnostic.goto_prev({ count = -1 })
end)
vim.keymap.set('n', '<leader>g', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', '<leader>ac', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>af', vim.lsp.buf.format)
vim.keymap.set('n', 'K', function ()
    vim.lsp.buf.hover({
        offset_x = 5,
        offset_y = 5,
    })
end)

return {
    { "b0o/schemastore.nvim" },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local fd = vim.loop.fs_scandir(
                vim.fn.stdpath('config') .. '/lua/vladimirdev635/plugins/lspconfig/configs'
            )
            for name in function() return vim.loop.fs_scandir_next(fd) end do
                require('vladimirdev635.plugins.lspconfig.configs.' .. name:gsub('.lua\z', ''))
            end
        end
    }
}
