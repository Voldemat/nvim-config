vim.keymap.set('n', ']g', function()
    vim.diagnostic.jump({ count = 1 })
end)
vim.keymap.set('n', '[g', function()
    vim.diagnostic.jump({ count = -1 })
    vim.diagnostic.open_float()
end)
vim.keymap.set('n', '<leader>g', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)

--- @param qf_entry vim.quickfix.entry
--- @return lsp.Location?
local function qf_entry_to_lsp_location(qf_entry)
    -- 1. Ensure the entry points to a valid buffer or file
    local bufnr = qf_entry.bufnr
    if (not bufnr or bufnr == 0) and qf_entry.filename then
        bufnr = vim.fn.bufadd(qf_entry.filename)
    end

    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return nil
    end

    -- 2. Resolve the absolute file URI
    local uri = vim.uri_from_bufnr(bufnr)

    -- 3. Adjust indexing (Vim lines/columns are 1-indexed; LSP is 0-indexed)
    -- If 'col' is missing, fallback to 1 (which becomes 0)
    local line = math.max(0, (qf_entry.lnum or 1) - 1)
    local col = math.max(0, (qf_entry.col or 1) - 1)

    -- 4. Construct the lsp.Location interface
    return {
        uri = uri,
        range = {
            start = { line = line, character = col },
            ["end"] = { line = line, character = col },
        }
    }
end
vim.keymap.set('n', 'gd', function()
    vim.lsp.buf.definition({
        on_list = function(options)
            local items = options.items
            -- Filter out declaration files (.d.ts) or node_modules
            --- @type vim.quickfix.entry[]
            local filtered = vim.tbl_filter(function(item)
                return not string.match(item.filename, ".nuxt")
            end, items)

            -- Fallback to original items if everything was filtered out
            if #filtered == 0 then filtered = items end

            if #filtered == 1 then
                local location = qf_entry_to_lsp_location(filtered[1])
                if location then
                    vim.lsp.util.show_document(location, "utf-8", {})
                end
            else
                vim.fn.setqflist({}, " ", { title = "Filtered Definitions", items = filtered })
                vim.cmd("copen")
            end
        end
    })
end)

local function check_code_action_support()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
        if client:supports_method('textDocument/codeAction', 0) then
            return true
        end
    end
    return false
end
vim.keymap.set('n', '<leader>ac', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>af', function()
    if check_code_action_support() then
        vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
        })
    end
    vim.lsp.buf.format({ async = true })
end, { desc = "LSP: Organize imports and format buffer" })
vim.keymap.set('n', 'K', function()
    vim.lsp.buf.hover({
        offset_x = 5,
        offset_y = 5,
    })
end)

return {
    { "b0o/schemastore.nvim" },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local fd = vim.loop.fs_scandir(
                vim.fn.stdpath('config') .. '/lua/vladimirdev635/plugins/lspconfig/configs'
            )
            for name in function() return vim.loop.fs_scandir_next(fd) end do
                require('vladimirdev635.plugins.lspconfig.configs.' .. name:gsub('.lua\z', ''))
            end
        end
    }
}
