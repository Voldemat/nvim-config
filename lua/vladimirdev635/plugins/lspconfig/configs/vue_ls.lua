vim.lsp.config('vue_ls', {
    cmd = function(dispatchers, config)
        local cmd = 'vue-language-server'
        if (config or {}).root_dir then
            local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', cmd)
            if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
            end
        end
        return vim.lsp.rpc.start({ cmd, '--stdio' }, dispatchers)
    end,
    root_dir = function(bufnr, on_dir)
        -- The project root is where the LSP can be started from
        -- As stated in the documentation above, this LSP supports monorepos and simple projects.
        -- We select then from the project root, which is identified by the presence of a package
        -- manager lock file.
        local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
        -- Give the root markers equal priority by wrapping them in a table
        root_markers = vim.fn.has('nvim-0.11.3') == 1 and { root_markers, { '.git' } }
            or vim.list_extend(root_markers, { '.git' })
        -- exclude deno
        local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
        local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
        local project_root = vim.fs.root(bufnr, root_markers)
        if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
            -- deno lock is closer than package manager lock, abort
            return
        end
        if deno_root and (not project_root or #deno_root >= #project_root) then
            -- deno config is closer than or equal to package manager lock, abort
            return
        end
        -- project is standard TS, not deno
        -- We fallback to the current working directory if no project root is found
        on_dir(project_root or vim.fn.getcwd())
    end,
})
vim.lsp.enable('vue_ls')
