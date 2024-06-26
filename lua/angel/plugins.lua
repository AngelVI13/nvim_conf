require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "cpp", "diff", "json", "lua", "go", "python", "typescript", "yaml"},

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

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
  -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
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

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
require('lspconfig')['pyright'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
}

require('lspconfig')['zls'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
}

require('lspconfig')['ocamllsp'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
}

require('lspconfig')['hls'].setup{
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
}

local rf_root = "/home/angel/Documents/RfGemini/GeminiRf/"

local rf_pythonpath = {
    rf_root .. "/test_scripts",
    rf_root .. "/lib/controller",
    rf_root .. "/lib/hil",
    rf_root .. "/lib/system",
    rf_root .. "/lib/common",
    rf_root .. "/resources",
}

require('lspconfig')['robotframework_ls'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
    settings = {
        robot = {
            pythonpath = rf_pythonpath,
            lint = {robocop = {enabled = true}},
            variables = {execdir = os.getenv('PWD')},
        },
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


vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.go' },
    callback = function()
        vim.lsp.buf.format({async = false})
    end,
    group = vim.api.nvim_create_augroup('GoFormatting', {}),
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

require('lspconfig').lua_ls.setup{
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

-- local opts = { noremap=true, silent=true }
-- vim.keymap.set("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", opts)
-- vim.keymap.set("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", opts)
-- vim.keymap.set("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", opts)
-- vim.keymap.set("n", "<F12>", "<Cmd>lua require'dap'.step_out()<CR>", opts)
-- vim.keymap.set("n", "<Leader>b", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
-- vim.keymap.set("n", "<Leader>B", "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opts)
-- vim.keymap.set("n", "<Leader>lp", "<Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", opts)
-- vim.keymap.set("n", "<Leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", opts)
-- vim.keymap.set("n", "<Leader>dl", "<Cmd>lua require'dap'.run_last()<CR>", opts)
-- vim.keymap.set("n", "<Leader>dt", "<Cmd>lua require'dap-go'.debug_test()<CR>", opts)
-- vim.keymap.set("n", "<Leader>dk", "<Cmd>lua require'dap'.terminate()<CR>", opts)
-- 
-- require('dap-go').setup()
-- require('dapui').setup()
-- require('nvim-dap-virtual-text').setup()
-- 
-- local dap, dapui = require("dap"), require("dapui")
-- dap.listeners.after.event_initialized["dapui_config"] = function()
--   dapui.open()
-- end
-- dap.listeners.before.event_terminated["dapui_config"] = function()
--   dapui.close()
-- end
-- dap.listeners.before.event_exited["dapui_config"] = function()
--   dapui.close()
-- end

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

require("oil").setup()

local trouble = require("trouble.providers.telescope")

local telescope = require("telescope")

telescope.setup {
  defaults = {
    mappings = {
      i = { ["<c-t>"] = trouble.open_with_trouble },
      n = { ["<c-t>"] = trouble.open_with_trouble },
    },
  },
}
vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end)
vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end)
vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end)
vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end)
vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end)
vim.keymap.set("n", "gr", function() require("trouble").toggle("lsp_references") end)

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- this is for diagnositcs signs on the line number column
-- use this to beautify the plain E W signs to more fun ones
-- !important nerdfonts needs to be setup for this to work in your terminal
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl= hl, numhl = hl })
end


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
