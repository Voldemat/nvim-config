return {
    "apple/pkl-neovim",
    lazy = true,
    ft = "pkl",
    build = function()
        require('pkl-neovim').init()
    end,
    config = function()
        vim.g.pkl_neovim = {
            start_command = { "java", "-jar", "/usr/local/share/java/pkl-lsp.jar" },
            pkl_cli_path = "/usr/local/bin/pkl"
        }
    end,
}
