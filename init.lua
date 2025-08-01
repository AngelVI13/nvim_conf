-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
	{ "blazkowolf/gruber-darker.nvim" },
	{ 'nvim-treesitter/nvim-treesitter', lazy = true },
	{ 'nvim-lua/plenary.nvim' },
	{ 'BurntSushi/ripgrep' },
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	{ 
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ 
				"nvim-telescope/telescope-live-grep-args.nvim" ,
				-- This will not install any breaking changes.
				-- For major updates, this must be adjusted manually.
				version = "^1.0.0",
			},
		},
		config = function()
			local telescope = require("telescope")

			-- first setup telescope
			telescope.setup({
				-- your config
			})

			-- then load the extension
			telescope.load_extension("live_grep_args")
			telescope.load_extension("fzf")
		end
	},
    	{ "nvim-telescope/telescope.nvim" },
	{ 'ThePrimeagen/harpoon' },
	{ "folke/todo-comments.nvim" },
	{ 'sbdchd/neoformat' },
	{ 'mbbill/undotree' },
	{ 'neovim/nvim-lspconfig' },
	{ 'hrsh7th/nvim-cmp',
		-- lazy = true,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			'hrsh7th/cmp-path',
			'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
		},
	},
	{ "nvim-telescope/telescope.nvim" },
	{ 'joerdav/templ.vim', lazy = true },
	{
		"dstein64/vim-startuptime",
		-- lazy-load on a command
		cmd = "StartupTime",
		-- init is called during startup. Configuration for vim plugins typically should be set in an init function
		init = function()
			vim.g.startuptime_tries = 10
		end,
	},
    { "jannis-baum/vivify.vim" },
    {
        "mason-org/mason.nvim",
        opts = {}
    },
    { "jubnzv/virtual-types.nvim", lazy = true },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- automatically check for plugin updates
  -- checker = { enabled = true },
})

vim.opt.background = "dark"
-- vim.cmd("colorscheme gruber")
vim.cmd("colorscheme gruber-darker")

-- ----------------

require'nvim-treesitter.configs'.setup {
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  highlight = {
    -- `false` will disable the whole extension
    enable = true,
  },
}


-- LSP
-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = 'buffer' },
    })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})


-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<leader>E', "<cmd>Telescope diagnostics<cr>", opts)
vim.keymap.set('n', '<leader>[', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<leader>]', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
vim.keymap.set('n', '<leader>t', "<cmd>TodoTelescope<cr>", opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local ruff_formatting = function(client, bufnr)
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            async = false,
          })

          -- Ruff proved import organization via the linter rather than the formatter.
          -- Call the corresponding code action here to get auto sort on save behavior analogous to e.g. clang-format.
          -- See https://github.com/astral-sh/ruff/issues/8926 for reference
          if client.name == "ruff" then
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" } },
              apply = true,
              buffer = bufnr,
            })
          end
        end,
      })
    end
end

local custom_on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    -- require("virtualtypes").on_attach(client, bufnr)
end

local py_on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    ruff_formatting(client, bufnr)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
require('lspconfig')['pyright'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
    settings = {
        pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
        },
        python = {
            analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { '*' },
            },
        },
    },
}

require('lspconfig')['ruff'].setup{
    on_attach = py_on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == 'ruff' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = 'LSP: Disable hover capability from Ruff',
})

require('lspconfig')['zls'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
}

require('lspconfig')['ocamllsp'].setup{
    on_attach = custom_on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
    settings = {
        codelens = { enable = true },
        inlayHints = { enable = true },
        syntaxDocumentation = { enable = true },
        duneDiagnostics = { enable = true },
        extendedHover = { enable = true },
        merlinJumpCodeActions = { enable = true },
    },
}

require("lspconfig").gopls.setup({
	cmd = { "gopls" },
	settings = {
		gopls = {
			analyses = {
				nilness = true,
				unusedparams = true,
				unusedwrite = true,
				useany = true,
                shadow = true,
                unusedvariable = true,
			},
			experimentalPostfixCompletions = true,
			gofumpt = true,  -- requires gofumpt installed
			staticcheck = true,
		},
	},
	on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
})

-- TODO: make a mechanism to switch this on and off
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.go' },
    callback = function()
        vim.lsp.buf.format({async = false})
    end,
    group = vim.api.nvim_create_augroup('GoFormatting', {}),
})

vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.ml' },
    callback = function()
        vim.lsp.buf.format({async = false})
    end,
    group = vim.api.nvim_create_augroup('OcamlFormatting', {}),
})

vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = { '*.go' },
    callback = function()
        vim.fn.execute("!golines -m 90 -w " .. vim.fn.expand("%"))
        vim.fn.execute(":e")
    end,
    group = vim.api.nvim_create_augroup('GoLinesFormatting', {}),
})

-- additional filetypes
vim.filetype.add({
 extension = {
  templ = "templ",
 },
})
require('lspconfig').templ.setup{}

local opts = { noremap=true, silent=true }
vim.keymap.set("n", "<Leader>H", "<Cmd>lua require'harpoon.mark'.add_file()<CR>", opts)
vim.keymap.set("n", "<Leader>h", "<Cmd>lua require'harpoon.ui'.toggle_quick_menu()<CR>", opts)
vim.keymap.set("n", "<Leader>1", "<Cmd>lua require'harpoon.ui'.nav_file(1)<CR>", opts)
vim.keymap.set("n", "<Leader>2", "<Cmd>lua require'harpoon.ui'.nav_file(2)<CR>", opts)
vim.keymap.set("n", "<Leader>3", "<Cmd>lua require'harpoon.ui'.nav_file(3)<CR>", opts)
vim.keymap.set("n", "<Leader>4", "<Cmd>lua require'harpoon.ui'.nav_file(4)<CR>", opts)
vim.keymap.set("n", "<Leader>5", "<Cmd>lua require'harpoon.ui'.nav_file(5)<CR>", opts)
vim.keymap.set("n", "<Leader>}", "<Cmd>lua require'harpoon.ui'.nav_next()<CR>", opts)
vim.keymap.set("n", "<Leader>{", "<Cmd>lua require'harpoon.ui'.nav_prev()<CR>", opts)

require('harpoon').setup()

require('todo-comments').setup({
  keywords = {
    FIX = { icon = "F ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
    TODO = { icon = "T ", color = "info" },
    HACK = { icon = "H ", color = "warning" },
    WARN = { icon = "W ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = "P ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = "N ", color = "hint", alt = { "INFO" } },
    TEST = { icon = "? ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
  }
})

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

vim.diagnostic.config({
  -- virtual_lines = {},
  virtual_text = {}
})


vim.api.nvim_create_user_command('CenterWindow',
  function()
      vim.cmd("60 vsplit")
      vim.cmd("wincmd w")
  end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command('OpenHarpoon1',
  function()
      require('harpoon.ui').nav_file(1)
  end,
  { nargs = 0 }
)

-- -----------------------------------
local function bind(op, outer_opts)
    outer_opts = outer_opts or {noremap = true}
    return function(lhs, rhs, opts)
        opts = vim.tbl_extend("force",
            outer_opts,
            opts or {}
        )
        vim.keymap.set(op, lhs, rhs, opts)
    end
end

nmap = bind("n", {noremap=false})
nnoremap = bind("n")
vnoremap = bind("v")
xnoremap = bind("x")
inoremap = bind("i")

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

nnoremap("<leader>z", "<cmd>:60 vsplit .<cr><C-w>l")
nnoremap("<leader>Z", "<C-w>o")

nnoremap("<leader>o", "<cmd>:copen 5<cr>")

-- this remap makes is so that i can paste the same thing multiple times but 
-- it makes pasting extra slow
-- xnoremap("p", "\"_dP")

-- ---------------------------------------

vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.smartindent = true

vim.opt.wrap = false

-- vim.api.nvim_set_option("clipboard", "unnamedplus")
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
    name = "xsel",
    copy = {
        ["+"] = "xsel --nodetach -i -b",
        ["*"] = "xsel --nodetach -i -p",
    },
    paste = {
        ["+"] = "xsel  -o -b",
        ["*"] = "xsel  -o -b",
    },
    cache_enabled = 1,
}

vim.opt.completeopt = {"menu", "menuone", "noselect"}

vim.opt.colorcolumn={"80", "90", "120"}
vim.opt.updatetime=250

vim.opt.grepprg = "rg -nH"

