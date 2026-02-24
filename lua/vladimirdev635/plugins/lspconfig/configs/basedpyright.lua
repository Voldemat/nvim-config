vim.lsp.config('basedpyright', {
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = 'on',
                useLibraryCodeForTypes = true,
                typeCheckingMode = 'on',
                autoImportCompletions = true,
                logLevel = "Trace"
            }
        }
    }
})
vim.lsp.enable('basedpyright')
