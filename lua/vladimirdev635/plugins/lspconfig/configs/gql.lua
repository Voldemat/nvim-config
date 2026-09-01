vim.lsp.config('gql', {
    filetypes = {
        'graphql',
    },
    cmd = {'gql', 'lsp'},
    --cmd = { '/Users/vladimir/code/opensource/graphql++/rust/cli/target/debug/cli', 'lsp' },
    root_markers = { 'gql.yaml' },
    workspace_required = true,
})
vim.lsp.enable('gql')
