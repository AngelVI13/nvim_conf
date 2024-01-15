vim.opt.background = "dark"

require("gruvbox").setup({
    contrast = "hard",
})

vim.cmd("colorscheme gruber")

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
      vim.cmd("wincmd w")
  end
})

vim.cmd.CenterWindow()
vim.cmd.OpenHarpoon1()
