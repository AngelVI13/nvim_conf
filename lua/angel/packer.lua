vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    -- Theme
    use "ellisonleao/gruvbox.nvim" 
    use {
      'https://gitlab.com/madyanov/gruber.vim',
      as = 'gruber.vim'
    }

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
    use {
        "nvim-telescope/telescope.nvim",
        requires = {
            { "nvim-telescope/telescope-live-grep-args.nvim" },
        },
        config = function()
            require("telescope").load_extension("live_grep_args")
        end
    }

    use 'ThePrimeagen/harpoon'

    -- LSP
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'L3MON4D3/LuaSnip'
    use 'hrsh7th/nvim-cmp'
    use 'ziglang/zig.vim'

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

    use 'sbdchd/neoformat'

    -- Debugger
    -- use 'mfussenegger/nvim-dap'
    -- use 'leoluz/nvim-dap-go'
    -- use 'rcarriga/nvim-dap-ui'
    -- use 'theHamsta/nvim-dap-virtual-text'
    -- use 'nvim-telescope/telescope-dap.nvim'

    use 'joerdav/templ.vim'
    use 'folke/trouble.nvim'
    use 'nvim-tree/nvim-web-devicons'
    use 'stevearc/oil.nvim'
    use 'mbbill/undotree'
end)

