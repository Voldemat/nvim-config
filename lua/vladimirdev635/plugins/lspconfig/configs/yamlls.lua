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
                    'templates/*/*.yaml',
                    'templates/*.yaml',
                    'templates/*/*/*.yaml',
                    'templates/*/*/*/*.yaml'
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
