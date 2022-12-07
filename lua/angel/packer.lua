vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    -- Theme
    use 'folke/tokyonight.nvim'
    use 'ayu-theme/ayu-vim'
    use "ellisonleao/gruvbox.nvim" 

    -- FZF
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    use 'nvim-lua/plenary.nvim'
    use 'BurntSushi/ripgrep'
    use 'nvim-telescope/telescope.nvim'

    -- LSP
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'L3MON4D3/LuaSnip'
    use 'hrsh7th/nvim-cmp'

    -- Todo highlihght
    use {
      "folke/todo-comments.nvim",
      requires = "nvim-lua/plenary.nvim",
      config = function()
        require("todo-comments").setup {
          signs = false,
        }
      end
    }
end)

