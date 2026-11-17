local M = {}

--- @return boolean
function M.format_code_block()
    local keeper = require("otter.keeper")
    local main_nr = vim.api.nvim_get_current_buf()
    if not keeper.has_raft(main_nr) then
        return false
    end

    -- find the fenced code block under the cursor in the markdown tree itself
    vim.treesitter.get_parser(main_nr):parse()
    local node = vim.treesitter.get_node({ bufnr = main_nr, ignore_injections = true })
    while node and node:type() ~= "fenced_code_block" do
        node = node:parent()
    end
    if not node then
        return false
    end

    local lang, open_row, open_col, close_row
    for child in node:iter_children() do
        local t = child:type()
        if t == "info_string" then
            local info = vim.treesitter.get_node_text(child, main_nr):match("^%S+")
            lang = vim.treesitter.language.get_lang(info) or info
        elseif t == "fenced_code_block_delimiter" then
            local r, c = child:range()
            if open_row == nil then open_row, open_col = r, c else close_row = r end
        end
    end
    if not lang then
        return false
    end
    close_row = close_row or select(3, node:range())

    local otter_nr = keeper.rafts[main_nr].buffers[lang]
    if not otter_nr then
        require("otter").deactivate()
        require("otter").activate()
        otter_nr = keeper.rafts[main_nr] and keeper.rafts[main_nr].buffers[lang]
        if not otter_nr then
            return false
        end
    end

    -- block lines without the fence's indentation (e.g. inside a list item)
    local first, last = open_row + 1, close_row -- 0-indexed, end-exclusive
    local lines = vim.api.nvim_buf_get_lines(main_nr, first, last, false)
    for i, l in ipairs(lines) do
        lines[i] = l:gsub("^" .. string.rep(" ?", open_col), "", 1)
    end

    -- format the block alone in the otter buffer with that language's LSP
    vim.api.nvim_buf_set_lines(otter_nr, 0, -1, false, lines)
    local client = vim.lsp.get_clients({ bufnr = otter_nr, method = "textDocument/formatting" })[1]
    if not client then
        return false
    end
    local params = {
        textDocument = { uri = vim.uri_from_bufnr(otter_nr) },
        options = { tabSize = vim.bo[otter_nr].shiftwidth, insertSpaces = vim.bo[otter_nr].expandtab },
    }
    local res, err = client:request_sync("textDocument/formatting", params, 3000, otter_nr)
    if not res or res.err then
        vim.notify("format failed: " .. vim.inspect(err or res.err), vim.log.levels.ERROR)
        return true
    end
    vim.lsp.util.apply_text_edits(res.result or {}, otter_nr, client.offset_encoding)
    local formatted = vim.api.nvim_buf_get_lines(otter_nr, 0, -1, false)

    local indent = string.rep(" ", open_col)
    for i, l in ipairs(formatted) do
        if l ~= "" then formatted[i] = indent .. l end
    end

    vim.api.nvim_buf_set_lines(main_nr, first, last, false, formatted)
    keeper.sync_raft(main_nr) -- restore the otter buffer
    return true
end

return M
