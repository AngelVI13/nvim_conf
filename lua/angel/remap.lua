local nnoremap = require("angel.keymap").nnoremap
local inoremap = require("angel.keymap").inoremap
local vnoremap = require("angel.keymap").vnoremap

nnoremap("<leader>D", "<cmd>Ex<CR>")

-- Adjust movement keys to always center the screen
nnoremap("<C-]>", "<C-]>zz")
nnoremap("<C-O>", "<C-O>zz")
nnoremap("<C-I>", "<C-I>zz")

inoremap("jk", "<C-[>")

-- FZF config
-- Using Lua functions
nnoremap("<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>")
nnoremap("<leader>fg", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>")
nnoremap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>")
nnoremap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>")

nnoremap("<leader>Q", "<cmd>e ~/.config/nvim<cr>")

nnoremap("<leader>z", "<cmd>:50 vsplit .<cr><C-w>l")
nnoremap("<leader>Z", "<C-w>o")
