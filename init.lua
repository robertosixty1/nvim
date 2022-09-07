local g = vim.g
local o = vim.o
local A = vim.api

A.nvim_command('syntax on')

o.termguicolors = true
o.background = 'dark'

-- o.hidden = true

-- Decrease update time
o.timeoutlen = 500
o.updatetime = 200

-- Number of screen lines to keep above and below the cursor
o.scrolloff = 8

-- Better editor UI
o.number = true
o.numberwidth = 2
o.relativenumber = true
o.signcolumn = 'yes'
o.cursorline = true

-- Colorscheme
local ok, _ = pcall(vim.cmd, 'colorscheme base16-dracula')

-- Better editing experience
o.expandtab = true
o.smarttab = true
o.cindent = true
o.autoindent = true
o.wrap = true
o.textwidth = 300
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = -1 -- If negative, shiftwidth value is used
o.list = true
o.mouse = 'a'
o.listchars = 'trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂'
-- o.listchars = 'eol:¬,space:·,lead: ,trail:·,nbsp:◇,tab:→-,extends:▸,precedes:◂,multispace:···⬝,leadmultispace:│   ,'
-- o.formatoptions = 'qrn1'

-- Makes neovim and host OS clipboard play nicely with each other
o.clipboard = 'unnamedplus'

-- Case insensitive searching UNLESS /C or capital in search
o.ignorecase = true
o.smartcase = true

-- Undo and backup options
o.backup = false
o.writebackup = false
o.undofile = true
o.swapfile = false
-- o.backupdir = '/tmp/'
-- o.directory = '/tmp/'
-- o.undodir = '/tmp/'

-- Remember 50 items in commandline history
o.history = 50

-- Better buffer splitting
o.splitright = true
o.splitbelow = true

g.mapleader = ' '
g.maplocalleader = ' '

-----------------------
-- PLUGINS
-----------------------

local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()
LSP_SERVERS = {"clangd", "rust_analyzer", "sumneko_lua"}

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'RRethy/nvim-base16'
    use 'kyazdani42/nvim-palenight.lua'

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup {
                options = { theme = 'dracula' },
            }
        end
    }

    -------------------
    -- LSP SERVERS
    -------------------

    use {
        "williamboman/mason.nvim",
        config = function()
            require('mason').setup()
        end
    }

    use {
        'neovim/nvim-lspconfig',
        config = function()
            local lc = require('lspconfig')
            for _, ls in ipairs(LSP_SERVERS) do
                lc[ls].setup{}
            end
        end
    }

    use {
        'hrsh7th/cmp-buffer',
        config = function()
            require('cmp').setup({
                sources = {
                    { name = 'buffer' },
                },
            })
        end
    }

    use {
        'hrsh7th/cmp-nvim-lsp',
        config = function()
            require'cmp'.setup {
                sources = {
                    { name = 'nvim_lsp' }
                }
            }

            -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

            local lc = require('lspconfig')
            for _, ls in ipairs(LSP_SERVERS) do
                lc[ls].setup{
                    capabilities = capabilities,
                }
            end
        end
    }

    use {
        'hrsh7th/nvim-cmp',
        config = function()
            local cmp = require'cmp'

            cmp.setup({
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
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
                 -- { name = 'vsnip' }, -- For vsnip users.
                    { name = 'luasnip' }, -- For luasnip users.
                 -- { name = 'ultisnips' }, -- For ultisnips users.
                 -- { name = 'snippy' }, -- For snippy users.
                },
                {
                    { name = 'buffer' },
                })
            })

            -- Set configuration for specific filetype.
            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
                },
                {
                    { name = 'buffer' },
                })
            })

            -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                },
                {
                    { name = 'cmdline' }
                })
            })

            -- Set up lspconfig.
            local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

            local lc = require('lspconfig')
            for _, ls in ipairs(LSP_SERVERS) do
                lc[ls].setup {
                    capabilities = capabilities
                }
            end
        end
    }

    use {
        'onsails/lspkind-nvim',
        config = function()
            require('lspkind').init({
                -- DEPRECATED (use mode instead): enables text annotations
                --
                -- default: true
                -- with_text = true,

                -- defines how annotations are shown
                -- default: symbol
                -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
                mode = 'symbol_text',

                -- default symbol map
                -- can be either 'default' (requires nerd-fonts font) or
                -- 'codicons' for codicon preset (requires vscode-codicons font)
                --
                -- default: 'default'
                preset = 'codicons',

                -- override preset symbols
                --
                -- default: {}
                symbol_map = {
                  Text = "",
                  Method = "",
                  Function = "",
                  Constructor = "",
                  Field = "ﰠ",
                  Variable = "",
                  Class = "ﴯ",
                  Interface = "",
                  Module = "",
                  Property = "ﰠ",
                  Unit = "塞",
                  Value = "",
                  Enum = "",
                  Keyword = "",
                  Snippet = "",
                  Color = "",
                  File = "",
                  Reference = "",
                  Folder = "",
                  EnumMember = "",
                  Constant = "",
                  Struct = "פּ",
                  Event = "",
                  Operator = "",
                  TypeParameter = ""
                },
            })
        end
    }

    use {
        'simrat39/symbols-outline.nvim',
        config = function()
            require("symbols-outline").setup()
        end
    }

    use {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            require("mason-lspconfig").setup()
        end
    }

    use 'saadparwaiz1/cmp_luasnip'
    use "L3MON4D3/LuaSnip"

    if packer_bootstrap then
        require('packer').sync()
    end
end)
