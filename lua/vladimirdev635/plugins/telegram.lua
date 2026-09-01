return {
    "ChuYanLon/telegram.nvim",
    build = "npm i",
    event = "VeryLazy",
    dependencies = {
        -- "folke/snacks.nvim",   -- optional: enables fuzzy-find chat picker
    },
    keys = {
        { "<leader>tt", "<cmd>Tg<Cr>",       desc = "Toggle Telegram" },
        { "<leader>tL", "<cmd>TgLogout<Cr>", desc = "Logout Telegram" },
        { "<leader>tp", "<cmd>TgPr<Cr>",     desc = "Create PR" },
        { "<leader>ti", "<cmd>TgIssue<Cr>",  desc = "Manage Issues" },
    },
    cmd = {
        "Tg",
        "TgLogout",
        "TgPr",
        "TgIssue",
    },
    opts = {

        tdlib_path = "/Users/vladimir/code/opensource/td/install/lib/libtdjson.dylib",         -- optional: .so (Linux) / .dylib (macOS) / .dll (Windows)
        -- proxy = "socks5://127.0.0.1:7890",             -- optional: for regions where Telegram is blocked
    },
}
