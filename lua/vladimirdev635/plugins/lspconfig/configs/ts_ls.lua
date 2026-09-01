local function range_contains_gt_7(range_str)
    -- 1. Wildcards (* or x) inherently include everything (>7)
    if range_str:find("%*") or range_str:lower():find("x") then
        return true
    end

    -- 2. Check for explicit relational conditions targeting high numbers
    -- e.g., >6, >=7, ^7.x, ~8.0
    for num in range_str:gmatch("(%d+)") do
        if tonumber(num) >= 7 then
            return true
        end
        break
    end

    -- 3. Handle explicit edge boundaries like ">6.5.0" which contains versions > 7
    local gt_match = range_str:match(">%s*(%d+)")
    if gt_match and tonumber(gt_match) >= 6 then
        return true
    end

    return false
end

vim.lsp.config('ts_ls', {
    filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'vue'
    },
    cmd = function(dispatchers, config)
        local cmd = 'typescript-language-server'
        local args = { '--stdio' }
        if (config or {}).root_dir then
            local package_json = vim.json.decode(table.concat(
                vim.fn.readfile(
                    vim.fs.joinpath(config.root_dir, 'package.json')
                )
            ))
            --- @type string?
            local typescript_version = nil
            if package_json.dependencies and package_json.dependencies.typescript then
                typescript_version = package_json.dependencies.typescript
            elseif package_json.devDependencies and package_json.devDependencies.typescript then
                typescript_version = package_json.devDependencies.typescript
            elseif package_json.peerDependencies and package_json.peerDependencies.typescript then
                typescript_version = package_json.peerDependencies.typescript
            end
            if typescript_version and range_contains_gt_7(typescript_version) then
                cmd = "tsc"
                args = { "--lsp", "--stdio" }
            end
            local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', cmd)
            if vim.fn.executable(local_cmd) == 1 then
                cmd = local_cmd
            end
        end
        local exec_args = vim.iter({ cmd, args }):flatten():totable()
        return vim.lsp.rpc.start(exec_args, dispatchers)
    end,
    before_init = function(first, config)
        local location = config.root_dir .. '/node_modules/@vue/language-server';
        first.initializationOptions = vim.tbl_deep_extend(
            "force",
            first.initializationOptions or {},
            {
                plugins = {
                    {
                        name = '@vue/typescript-plugin',
                        location = location,
                        languages = { 'vue' },
                    },
                },
            }
        )
        return true
    end,
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentFormattingRangeProvider = false
    end,
})
vim.lsp.enable('ts_ls')
