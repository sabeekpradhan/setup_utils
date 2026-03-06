-- =============================================================================
-- Tested on nvim v0.11.5, installed using `sudo snap install nvim --classic`
-- ~/.config/nvim/init.lua
-- lazy.nvim · Telescope · nvim-tree · treesitter · LSP · nvim-cmp
-- LSP servers: pyright, ruff, ruby-lsp, ts_ls, rust-analyzer
-- =============================================================================
-- Shortcuts (leader = backslash '\')
-- -----------------------------------------------------------------------------
-- Telescope:
--   Ctrl-p        Fuzzy find git files
--   \b            Fuzzy find open buffers
--   Ctrl-f        Live grep across project
--   \s            Find document symbols (functions, classes, etc.)
--
-- nvim-tree:
--   \t            Toggle file explorer sidebar
--   \tf           Reveal current file in tree
--
-- LSP:
--   K             Show hover docs / type info
--   gd            Go to definition
--   gr            List references
--   \rn           Rename symbol
--   \ca           Code action
--   [d / ]d       Jump to prev/next diagnostic
--   \e            Show diagnostic in floating window
--   Ctrl-O        Return to the previous context after going to a definition/reference.
--
-- Folds (treesitter-based, top-level open by default):
--   za            Toggle fold under cursor
--   zo / zc       Open / close one fold
--   zR / zM       Open all / close all folds
--
-- Completion (nvim-cmp):
--   Tab / S-Tab   Next / previous item
--   CR            Confirm selection
--   C-Space       Trigger completion
--   C-e           Dismiss menu
--
-- Splits & Windows:
--   :vs / :Vs     Vertical split
--   :sp           Horizontal split
--   Ctrl-j / k    Switch between splits
--
-- Tabs:
--   Ctrl-n        New tab
--   Ctrl-x        Close tab (with confirmation)
--   Ctrl-h / l    Switch tabs left/right
--
-- General:
--   :TwoSpace     Set indent to 2 spaces
--   :FourSpace    Set indent to 4 spaces
--   :C / :U       Comment/uncomment lines (visual, filetype-aware)
-- =============================================================================

-- =============================================================================
-- BOOTSTRAP lazy.nvim (replaces Vundle)
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader must be set before lazy loads plugins
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- Disable netrw before any plugin loads (nvim-tree replaces it)
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- =============================================================================
-- PLUGINS
-- =============================================================================
require("lazy").setup({

  -- Telescope: fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { preview_width = 0.55 },
          file_ignore_patterns = { "node_modules", ".git/", "__pycache__" },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- nvim-tree: file explorer sidebar
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 35 },
        renderer = {
          group_empty = true,
          icons = { show = { file = true, folder = true, git = true } },
        },
        filters = { dotfiles = false },
        git = { enable = true },
      })
    end,
  },

  -- Treesitter: semantic syntax highlighting + smarter indentation
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Add plugin's runtime/ dir to rtp so bundled queries (folds, indents,
      -- highlights) are available for all languages, even without tree-sitter-cli
      vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime")
      -- Enable treesitter-based indentation for all buffers
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- LSP: installer (config uses Neovim 0.11 native vim.lsp.config)
  {
    "williamboman/mason.nvim",
    config = function() require("mason").setup() end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",       -- Python type checking + hover docs
          "ruff",          -- Python linting + formatting (replaces flake8/black)
          "ruby_lsp",      -- Ruby / Rails
          "ts_ls",         -- TypeScript / Next.js
          "rust_analyzer", -- Rust
        },
        automatic_installation = true,
      })
    end,
  },

  -- LSP server configurations (provides cmd/filetypes/root_markers for vim.lsp.enable)
  { "neovim/nvim-lspconfig" },

  -- Autocompletion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Colorscheme (ron equivalent that works well in kitty true-color)
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme kanagawa-dragon") -- dark, low-noise, similar vibe to ron
    end,
  },

})

-- =============================================================================
-- GENERAL SETTINGS (ported directly from your vimrc)
-- =============================================================================
local opt = vim.opt

opt.scrolloff     = 5
opt.foldmethod    = "expr"
opt.foldexpr      = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable    = true
opt.foldlevel     = 1      -- top-level folds open; nested folds closed
opt.wrap          = false
opt.modeline      = false
opt.swapfile      = false
opt.number        = true
opt.termguicolors = true
opt.signcolumn    = "yes"   -- always show, avoids layout shifts from LSP diagnostics

-- Default indent: 2 spaces (same as your vimrc)
opt.tabstop      = 2
opt.softtabstop  = 2
opt.shiftwidth   = 2
opt.expandtab    = true

-- Wildmenu
opt.wildmode     = "list:full"
opt.wildignore:append("*.swp,*.bak,*.pyc,*.class,*.o,*.obj,*.a,*.dep,*.exe")

-- =============================================================================
-- KEYMAPS (all original bindings preserved)
-- =============================================================================
local map = vim.keymap.set

-- Disable F1
map("n", "<F1>", "<Cmd>echo<CR>")
map("i", "<F1>", "<C-o><Cmd>echo<CR>")

-- Split navigation: Ctrl-j / Ctrl-k
map("n", "<C-j>", "<C-w><S-w>")
map("n", "<C-k>", "<C-w>w")

-- Tab management (unchanged)
map("n", "<C-n>", "<Cmd>tabnew<CR>")
map("n", "<C-h>", "gT")
map("n", "<C-l>", "gt")
map("v", "<C-n>", "<Cmd>tabnew<CR>")
map("v", "<C-h>", "gT")
map("v", "<C-l>", "gt")

-- Close tab with confirmation
map("n", "<C-x>", function()
  if vim.fn.confirm("Close tab?", "&yes\n&no", 1) == 1 then
    vim.cmd("tabclose")
  end
end)
map("v", "<C-x>", function()
  if vim.fn.confirm("Close tab?", "&yes\n&no", 1) == 1 then
    vim.cmd("tabclose")
  end
end)

-- Telescope keymaps
map("n", "<C-p>", "<Cmd>Telescope git_files<CR>")
map("n", "<leader>b", "<Cmd>Telescope buffers<CR>")
map("n", "<C-f>", "<Cmd>Telescope live_grep<CR>")
map("n", "<leader>s", "<Cmd>Telescope lsp_document_symbols<CR>") -- functions/classes list

-- nvim-tree
map("n", "<leader>t",  "<Cmd>NvimTreeToggle<CR>")
map("n", "<leader>tf", "<Cmd>NvimTreeFindFile<CR>")

-- LSP keymaps (set on attach below)
-- K, gd, gr, \rn, \ca, [d, ]d, \e

-- =============================================================================
-- COMMANDS (unchanged)
-- =============================================================================
vim.cmd([[cnoreabbrev <expr> Vs getcmdtype() == ':' && getcmdline() ==# 'Vs' ? 'vs' : 'Vs']])
vim.api.nvim_create_user_command("TwoSpace",  "set shiftwidth=2 | set softtabstop=2", {})
vim.api.nvim_create_user_command("FourSpace", "set shiftwidth=4 | set softtabstop=4", {})

-- =============================================================================
-- AUTOCMDS (ported from your vimrc)
-- =============================================================================

-- CUDA filetype overrides (Neovim handles most filetypes natively)
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = { "*.cu", "*.cu.cc" },
  callback = function() vim.bo.filetype = "cpp" end,
})

-- Trailing whitespace highlighting
local ws_group = vim.api.nvim_create_augroup("TrailingWhitespace", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = ws_group,
  callback = function()
    vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#555555" })
  end,
})
vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#555555" })
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = ws_group,
  callback = function() vim.fn.matchadd("ExtraWhitespace", [[\s\+$]]) end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
  group = ws_group,
  callback = function() vim.fn.matchadd("ExtraWhitespace", [[\s\+\%#\@<!$]]) end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = ws_group,
  callback = function() vim.fn.matchadd("ExtraWhitespace", [[\s\+$]]) end,
})

-- =============================================================================
-- PYTHON SETTINGS (ported)
-- =============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.softtabstop  = 4
    vim.opt_local.tabstop      = 4
    vim.opt_local.shiftwidth   = 4
    -- Comment / uncomment commands
    vim.api.nvim_buf_create_user_command(0, "C",
      [[<line1>,<line2> s/\(.*\)/#\1/g]], { range = true })
    vim.api.nvim_buf_create_user_command(0, "U",
      [[<line1>,<line2> s/\(\s*\)#\(.*\)/\1\2/g]], { range = true })
  end,
})

-- =============================================================================
-- VIM FILE SETTINGS (ported)
-- =============================================================================
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.vim", "*.vimrc" },
  callback = function()
    vim.api.nvim_buf_create_user_command(0, "C",
      [[<line1>,<line2> s/\(.*\)/"\1/g]], { range = true })
    vim.api.nvim_buf_create_user_command(0, "U",
      [[<line1>,<line2> s/[ ]*"\(.*\)/\1/g]], { range = true })
  end,
})

-- =============================================================================
-- LSP SETUP
-- =============================================================================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Shared on_attach: sets LSP keymaps for any buffer with an active server
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "K",       vim.lsp.buf.hover,           opts)
  vim.keymap.set("n", "gd",      vim.lsp.buf.definition,      opts)
  vim.keymap.set("n", "gr",      vim.lsp.buf.references,      opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,       opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,  opts)
  vim.keymap.set("n", "<leader>e",  vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d",      function() vim.diagnostic.jump({ count = -1 }) end, opts)
  vim.keymap.set("n", "]d",      function() vim.diagnostic.jump({ count = 1 }) end,  opts)
end

-- Per-server configs using vim.lsp.config (Neovim 0.11 native API)
vim.lsp.config('pyright', {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    python = {
      pythonPath = os.getenv("VIRTUAL_ENV")
        and (os.getenv("VIRTUAL_ENV") .. "/bin/python")
        or nil,
    },
  },
})

vim.lsp.config('ruff', {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false
    on_attach(client, bufnr)
  end,
})

vim.lsp.config('ruby_lsp', {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config('ts_ls', {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config('rust_analyzer', {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = { command = "clippy" },
    },
  },
})

vim.lsp.enable({ 'pyright', 'ruff', 'ruby_lsp', 'ts_ls', 'rust_analyzer' })

-- =============================================================================
-- COMPLETION (nvim-cmp)
-- =============================================================================
local cmp     = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"]   = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"]    = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"]   = cmp.mapping.abort(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSP completions (types, methods, etc.)
    { name = "luasnip"  }, -- snippets
  }, {
    { name = "buffer" },   -- words in current buffer
    { name = "path"   },   -- filesystem paths
  }),
  -- Show type signatures in completion menu
  formatting = {
    format = function(_, item)
      item.menu = item.kind
      return item
    end,
  },
})

-- =============================================================================
-- DIAGNOSTICS DISPLAY
-- =============================================================================
vim.diagnostic.config({
  update_in_insert = false, -- don't flicker while typing
  severity_sort   = true,
})
