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

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup {
                options = { theme = 'dracula' },
            }
        end
    }

    use 'RRethy/nvim-base16'
    use 'kyazdani42/nvim-palenight.lua'

    -------------------
    -- LSP SERVERS
    -------------------

    use 'p00f/clangd_extensions.nvim'
    use 'simrat39/rust-tools.nvim'
    use 'folke/lua-dev.nvim'

    use {
        'junnplus/lsp-setup.nvim',
        requires = {
            'neovim/nvim-lspconfig',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
        },
        config = function()
            require('lsp-setup').setup {
                servers = {
                    rust_analyzer = require('lsp-setup.rust-tools').setup({
                        server = {
                            settings = {
                                ['rust-analyzer'] = {
                                    cargo = {
                                        loadOutDirsFromCheck = true,
                                    },
                                    procMacro = {
                                        enable = true,
                                    },
                                },
                            },
                        },
                    }),
                    clangd = require('lsp-setup.clangd_extensions').setup({}),
                    sumneko_lua = require('lua-dev').setup({
                        lspconfig = {
                            settings = {
                                Lua = {
                                    format = {
                                        enable = true,
                                    }
                                }
                            }
                        }
                    }),
                }
            }
            --A.nvim_command('LspStart')
        end
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)
