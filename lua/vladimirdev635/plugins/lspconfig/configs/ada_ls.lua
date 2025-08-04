vim.filetype.add({
  extension = {
    gpr = 'gpr',
    adb = 'adb'
  }
})

vim.treesitter.language.register('ada', 'gpr')
vim.treesitter.language.register('ada', 'adb')

vim.lsp.config('ada_ls', {
    filetypes = { 'adb' }
})
vim.lsp.enable('ada_ls')

vim.lsp.config('ada_ls_gpr', {
    cmd = { 'ada_language_server', '--language-gpr' },
    filetypes = { 'gpr' },
    root_markers = { '.alire.toml', '.git' },
})
vim.lsp.enable('ada_ls_gpr')
