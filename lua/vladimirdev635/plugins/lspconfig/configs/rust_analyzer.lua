vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = {
            cargo = {
                allFeatures = true
            },
            imports = {
                prefix = "self"
            },
            check = {
                command = "clippy",
            },
        },
    },
    capabilities = {
        textDocument = {
            completion = {
                completionItem = {
                    snippetSupport = false
                }
            }
        }
    }
})
vim.lsp.enable('rust_analyzer')
