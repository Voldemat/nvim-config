vim.keymap.set('v', '<leader>s', function()
    require("nvim-silicon").clip()
end)
return {
    {
        'michaelrommel/nvim-silicon',
        opts = {
            theme = "catppuccin",
        }
    },
}
