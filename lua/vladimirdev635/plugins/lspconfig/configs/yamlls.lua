vim.lsp.config('yamlls', {
    settings = {
        yaml = {
            hover = true,
            validate = true,
            format = {
                enable = true,
                singleQuote = true,
                printWidth = 2
            },
            schemas = {
                kubernetes = {
                    'helm/*/templates/*/*.yaml',
                    'helm/*/templates/*.yaml',
                    'helm/*/templates/*/*/*.yaml',
                    'helm/*/templates/*/*/*/*.yaml'
                }
            }
        },
    },
    capabilities = {
        workspace = {
            didChangeConfiguration = {
                dynamicRegistration = true
            }
        }
    }
})
vim.lsp.enable('yamlls')
