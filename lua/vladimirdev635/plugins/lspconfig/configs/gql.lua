local parser_lib_ext = vim.uv.os_uname().sysname == "Darwin" and "dylib" or "so"
--- @param path string
--- @return string?
local function read_file_uv(path)
    local fd = vim.uv.fs_open(path, "r", 438)
    if not fd then return nil end
    local stat = vim.uv.fs_fstat(fd)
    if not stat then return nil end
    local content = vim.uv.fs_read(fd, stat.size, 0)
    vim.uv.fs_close(fd)
    return content
end

--- @class GQLSources
--- @field client string[]
--- @field server string[]

--- @param bufnr number
--- @param gql_sources GQLSources
--- @param root_path string
--- @return ("server" | "client")?
local function get_file_type_of_bufnr(bufnr, gql_sources, root_path)
    local buf_path = vim.api.nvim_buf_get_name(bufnr)
    for _, pattern in ipairs(gql_sources.server) do
        local absolute_path = vim.fs.normalize(vim.fs.joinpath(root_path, pattern))
        if vim.glob.to_lpeg(absolute_path):match(buf_path) then
            return "server"
        end
    end
    for _, pattern in ipairs(gql_sources.client) do
        local absolute_path = vim.fs.normalize(vim.fs.joinpath(root_path, pattern))
        if vim.glob.to_lpeg(absolute_path):match(buf_path) then
            return "client"
        end
    end
    return nil
end

--- @param bufnr number
--- @param version string
--- @param gql_sources GQLSources
--- @param root_path string
local function start_treesitter(bufnr, version, gql_sources, root_path)
    local file_type = get_file_type_of_bufnr(bufnr, gql_sources, root_path)
    if not file_type then
        return
    end
    local lang = "gql-" .. version .. "-" .. file_type
    local treesitter_folder_path = "/Users/vladimir/.local/state/gqlup/versions/" .. version .. "/treesitter/"
    if vim.treesitter.language.add(lang, {
            path = treesitter_folder_path .. "parser." .. file_type .. "." .. parser_lib_ext,
            symbol_name = "gql_" .. file_type
        }) then
        local shared_highlights = read_file_uv(
            vim.fs.joinpath(
                treesitter_folder_path,
                "queries",
                "highlights.shared.csm"
            )
        )
        local type_specific_highlights = read_file_uv(
            vim.fs.joinpath(
                treesitter_folder_path,
                "queries",
                "highlights." .. file_type .. ".csm"
            )
        )
        --- @type string?
        local combined_highlights = nil
        if shared_highlights ~= nil and type_specific_highlights ~= nil then
            combined_highlights = shared_highlights .. "\n" .. type_specific_highlights
        end
        if combined_highlights then
            vim.treesitter.query.set(lang, "highlights", combined_highlights)
        end
        vim.treesitter.start(bufnr, lang)
        vim.bo.filetype = lang
    end
end

vim.lsp.config('gql', {
    filetypes = {
        'graphql',
    },
    cmd = { 'gql', 'lsp' },
    --cmd = { '/Users/vladimir/code/opensource/graphql++/rust/cli/target/debug/cli', 'lsp' },
    root_markers = { 'gql.yaml' },
    workspace_required = true,
    --- @param client vim.lsp.Client
    on_init = function(client)
        client:request('workspace/executeCommand', {
            command = 'gql.GetGQLSourcePatterns',
            arguments = {},
        }, function(err, result)
            if err then
                vim.notify('LSP command error: ' .. err.message, vim.log.levels.ERROR)
            else
                client.gql_sources = result
                for bufnr, _ in pairs(client.attached_buffers) do
                    start_treesitter(bufnr, client.server_info.version, client.gql_sources, client.root_dir)
                end
            end
        end)
    end,
    --- @param client vim.lsp.Client
    --- @param bufnr number
    on_attach = function(client, bufnr)
        if client.gql_sources then
            start_treesitter(bufnr, client.server_info.version, client.gql_sources, client.root_dir)
        end
    end
})
vim.lsp.enable('gql')
