vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = {
            cargo = {
                target = 'x86_64-unknown-linux-gnu'
            }
        }
    }
})
vim.lsp.enable('rust_analyzer')
