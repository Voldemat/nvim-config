local M = {}

-- Build the reverse lookup table (number -> string)
local completion_kind_names = {}
for name, idx in pairs(vim.lsp.protocol.CompletionItemKind) do
  completion_kind_names[idx] = name
end

--- Apply completion insertion into the source buffer
--- @param word_end_pos vim.Pos
--- @param word string
--- @param item CompletionItem
--- @param target_bufnr integer
local function apply_completion(word_end_pos, word, item, target_bufnr)
    if word ~= item.insert_text then
        vim.api.nvim_buf_set_text(
            0,
            word_end_pos.row,
            word_end_pos.col - #word + 1,
            word_end_pos.row,
            word_end_pos.col + 1,
            {}
        )
        local current_cursor_position = vim.api.nvim_win_get_cursor(0)
        local cursor_col = word_end_pos.col - #word + 1
        vim.api.nvim_win_set_cursor(0, {word_end_pos.row + 1, cursor_col})
        vim.api.nvim_put({item.insert_text}, "b", false, false)
        vim.api.nvim_win_set_cursor(0, current_cursor_position)
    end

    if item.additional_inserts then
        local client = vim.lsp.get_clients({ bufnr = target_bufnr })[1]
        if client then
            vim.lsp.util.apply_text_edits(item.additional_inserts, target_bufnr, client.offset_encoding)
        end
    end
end

--- @return string, vim.Pos
local function get_word_and_start_pos()
    local word = vim.fn.expand('<cword>')
    local cur_pos = vim.api.nvim_win_get_cursor(0)

    -- Search backward ('b') to find the start of the word, accepting match at cursor ('c')
    vim.fn.search(word, 'ce')
    local end_pos = vim.api.nvim_win_get_cursor(0)

    -- Unpack the {row, col} tuple directly
    local pos = vim.pos.cursor(0, end_pos)

    -- Restore the user's cursor back to its original position
    vim.api.nvim_win_set_cursor(0, cur_pos)

    return word, pos
end

--- @class CompletionItem
--- @field insert_text string
--- @field kind string
--- @field display_text string
--- @field additional_inserts lsp.TextEdit[]
--- @field source_name string

--- @param word string
--- @param pos vim.Pos
--- @param callback fun(completions: CompletionItem[])
local function get_lsp_completions(word, pos, callback)
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        method = "textDocument/completion"
    })

    if #clients == 0 then
        vim.notify("No active LSP clients support completion for this buffer.", vim.log.levels.WARN)
        return
    end

    -- Get current cursor parameters for the LSP request
    --- @type lsp.TextDocumentPositionParams
    local params = {
        textDocument = vim.lsp.util.make_text_document_params(bufnr),
        position = vim.pos.to_lsp(pos, clients[1].offset_encoding)
    }

    -- Send asynchronous completion request to all attached LSP servers
    vim.lsp.buf_request(bufnr, "textDocument/completion", params, function(err, result, ctx)
        if err then
            vim.notify("LSP Completion Error: " .. err.message, vim.log.levels.ERROR)
            return
        end

        if not result then
            print("No completion results returned.")
            return
        end

        --- @type vim.lsp.CompletionResult
        local response = result

        local items = response.items or response

        -- Filter or process items based on your target word
        --- @type CompletionItem[]
        local matches = {}
        for _, item in ipairs(items) do
            local insert_text = item.label or item.insertText
            if not insert_text:find(word, 1, true) then
                goto continue
            end
            local display_text = insert_text
            if item.labelDetails and item.labelDetails.detail then
                display_text = display_text .. item.labelDetails.detail
            end
            --- @type CompletionItem
            local completion_item = {
                display_text = display_text,
                insert_text = insert_text,
                kind = completion_kind_names[item.kind] or "",
                source_name = vim.lsp.get_client_by_id(ctx.client_id).name,
                additional_inserts = item.additionalTextEdits or {}
            }
            table.insert(matches, completion_item)
            ::continue::
        end
        callback(matches)
    end)
end

--- @param word string
--- @param pos vim.Pos
--- @param callback fun(completions: CompletionItem[])
local function fetch_completions_for_word(word, pos, callback)
    get_lsp_completions(word, pos, callback)
end

--- @type integer
WIN_HANDLE = nil

-- --- @param pos vim.Pos
-- --- @param completions CompletionItem[]
--local function show_selections_menu(pos, completions)
--    if WIN_HANDLE == nil then
--        local buf = vim.api.nvim_create_buf(false, true)
--        local width = 40
--        local height = 10
--        local opts = {
--            relative = 'editor',
--            width = width,
--            height = height,
--            row = pos.row,
--            col = pos.col,
--            style = 'minimal',
--            border = 'rounded'
--        }
--        WIN_HANDLE = vim.api.nvim_open_win(buf, true, opts)
--    end
--end

--- @param word_end_pos vim.Pos
--- @param word string
--- @param completions CompletionItem[]
local function show_selections_menu(word_end_pos, word, completions)
    local source_win = vim.api.nvim_get_current_win()
    local source_buf = vim.api.nvim_get_current_buf()

    -- Calculate menu dimensions
    local max_width = 30
    local display_lines = {}
    for _, item in ipairs(completions) do
        table.insert(display_lines, item.display_text .. " [" .. item.kind .."][" .. item.source_name .. "]")
        max_width = math.max(max_width, #item.display_text + 4)
    end

    -- Create scratch buffer for floating menu
    local float_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, display_lines)

    local height = math.min(#completions, 10)
    local win_opts = {
        relative = 'cursor',
        row = 1,
        col = 0,
        width = max_width,
        height = height,
        style = 'minimal',
        border = 'rounded',
        focusable = true,
    }

    local float_win = vim.api.nvim_open_win(float_buf, true, win_opts)

    -- Window styling & behavior
    vim.wo[float_win].cursorline = true
    vim.bo[float_buf].modifiable = false
    vim.bo[float_buf].buftype = 'nofile'

    local function close_menu()
        if vim.api.nvim_win_is_valid(float_win) then
            vim.api.nvim_win_close(float_win, true)
        end
    end

    local function confirm_selection()
        local cursor = vim.api.nvim_win_get_cursor(float_win)
        local selected_idx = cursor[1]
        local item = completions[selected_idx]

        close_menu()
        vim.api.nvim_set_current_win(source_win)

        if item then
            apply_completion(word_end_pos, word, item, source_buf)
        end
    end

    -- Keymaps for navigation within the menu
    local keymap_opts = { buffer = float_buf, noremap = true, silent = true }

    -- Navigate Down (<C-n> / j)
    --vim.keymap.set('n', 'j', 'j', keymap_opts)
    --vim.keymap.set('n', '<C-n>', 'j', keymap_opts)

    -- Navigate Up (<C-p> / k)
    --vim.keymap.set('n', 'k', 'k', keymap_opts)
    --vim.keymap.set('n', '<C-p>', 'k', keymap_opts)

    -- Select item (<CR> / <Tab>)
    vim.keymap.set('n', '<C-y>', confirm_selection, keymap_opts)
    --vim.keymap.set('n', '<Tab>', confirm_selection, keymap_opts)

    -- Close menu (<Esc> / q)
    vim.keymap.set('n', '<Esc>', close_menu, keymap_opts)
    --vim.keymap.set('n', 'q', close_menu, keymap_opts)
end


local show_selections_for_word_under_cursor = function()
    local word, pos = get_word_and_start_pos()
    --- @type CompletionItem[]
    local completions = {}
    fetch_completions_for_word(word, pos, function(new_completions)
        for i = 1, #new_completions do
            completions[#completions + 1] = new_completions[i]
        end
        show_selections_menu(pos, word, completions)
    end)
end
vim.keymap.set('n', '<leader>ca', show_selections_for_word_under_cursor)
M.setup = function()
end

return M
