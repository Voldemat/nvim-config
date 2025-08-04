vim.lsp.config('jsonls', {
    cmd = { 'vscode-json-languageserver', '--stdio' },
    settings = {
        json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
        },
    },
})
vim.lsp.enable('jsonls')
