vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = {
            cargo = {
            }
        }
    }
})
vim.lsp.enable('rust_analyzer')
