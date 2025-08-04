vim.lsp.config('clangd', {
    cmd = { "clangd", "--log=verbose", "--enable-config" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }
})
vim.lsp.enable('clangd')
