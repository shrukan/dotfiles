local keymap = vim.keymap

-- copy clipboard
keymap.set({ "n", "x", "o" }, "gy", '"+y', { desc = "Copy to clipboard" })
keymap.set({ "n", "x", "o" }, "gp", '"+p', { desc = "Paste clipboard text" })

keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the bottom window" })
keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the top window" })
