-- =============================================================================
-- Tested on nvim v0.11.6, installed using `sudo snap install nvim --classic`
-- ~/.config/nvim/init.lua
-- lazy.nvim · Telescope · nvim-tree · treesitter · LSP · nvim-cmp
-- LSP servers: pyright, ruff, ruby-lsp, ts_ls, rust-analyzer
-- =============================================================================
-- Shortcuts (leader = backslash '\')
-- -----------------------------------------------------------------------------
-- Telescope:
--   Ctrl-p        Fuzzy find files (incl. gitignored + hidden; prunes deps/output)
--   \p            Fuzzy find files EVERYWHERE incl. .venv/build/output (slow)
--   \b            Fuzzy find open buffers
--   Ctrl-f        Live grep across project
--   \s            Find document symbols (functions, classes, etc.)
--
-- nvim-tree:
--   \t            Toggle file explorer sidebar
--   \tf           Reveal current file in tree
--
-- Aerial (code outline sidebar):
--   \a            Toggle aerial outline sidebar
--   o             Toggle expand/collapse a node
--   l / h         Expand / collapse a node
--   zo / zc       Expand / collapse (standard Vim fold keys also work)
--
-- LSP:
--   K             Show hover docs / type info
--   gd            Go to definition
--   gr            List references
--   \rn           Rename symbol (writes every file the rename touched)
--   \ca           Code action (likewise, when the action spans files)
--   u / Ctrl-R    Undo/redo a multi-file rename across all of its files at once,
--                 while it is still the newest change in the file you are in;
--                 ordinary undo/redo otherwise
--   [d / ]d       Jump to prev/next diagnostic
--   \e            Show diagnostic in floating window
--   Ctrl-O        Return to the previous context after going to a definition/reference.
--
-- Folds (treesitter-based, all open by default):
--   za            Toggle fold under cursor
--   zo / zc       Open / close one fold
--   zO / zC       Open all / close all folds
--
-- Completion (nvim-cmp):
--   Tab / S-Tab   Next / previous item
--   <Enter>       Confirm selection
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
-- Clipboard:
--   Ctrl-c        Copy selection to system clipboard (visual) / copy line (normal)
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

-- Debian/Ubuntu's fd-find package installs the binary as `fdfind`, not `fd`.
-- Detect the real name once; used by Telescope find_files below and the \p map.
local fd_bin = vim.fn.executable("fd") == 1 and "fd" or "fdfind"

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
          file_ignore_patterns = {
            "node_modules", ".git/", "__pycache__", ".venv", "venv",
            "%.o$", "%.obj$", "%.a$", "%.lib$", "%.so$", "%.dylib$", "%.dll$", "%.exe$",
            "%.pyc$", "%.pyo$", "%.class$", "%.jar$",
            "%.png$", "%.jpg$", "%.jpeg$", "%.gif$", "%.bmp$", "%.ico$", "%.webp$",
            "%.pdf$", "%.zip$", "%.tar$", "%.gz$", "%.bz2$", "%.xz$", "%.7z$", "%.rar$",
            "%.woff$", "%.woff2$", "%.ttf$", "%.eot$",
            "%.mp3$", "%.mp4$", "%.avi$", "%.mov$", "%.mkv$",
            "%.db$", "%.sqlite$", "%.sqlite3$", "%.npy$", "%.npz$",
            "%.pickle$", "%.pkl$", "%.parquet$", "%.feather$", "%.h5$", "%.hdf5$",
          },
        },
        pickers = {
          -- Include gitignored + hidden files (so .env, .github/, generated
          -- configs, etc. are findable), but use --no-ignore-vcs rather than
          -- --no-ignore so fd/rg STILL honor .ignore files. That lets us prune
          -- the few giant dirs (deps + build/eval output) at traversal time —
          -- file_ignore_patterns can't, since it filters only AFTER the walk,
          -- which is what made Ctrl-P slow. Repo-specific giants live in each
          -- repo's .ignore; the always-junk ones are excluded here.
          find_files = {
            find_command = {
              fd_bin, "--type", "f", "--color", "never",
              "--hidden", "--no-ignore-vcs",
              "--exclude", ".git",
              "--exclude", ".venv",
              "--exclude", "venv",
              "--exclude", "node_modules",
              "--exclude", "__pycache__",
            },
          },
          live_grep = {
            additional_args = {
              "--no-ignore-vcs", "--hidden",
              "--glob", "!.git",
              "--glob", "!.venv",
              "--glob", "!venv",
              "--glob", "!node_modules",
              "--glob", "!__pycache__",
            },
          },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- aerial: code outline sidebar
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("aerial").setup({
        backends = { "treesitter", "lsp" },
        layout = {
          min_width = 30,
          default_direction = "left",
        },
        filter_kind = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Method",
          "Module",
          "Namespace",
          "Struct",
        },
        keymaps = {
          ["<C-j>"] = false,
          ["<C-k>"] = false,
        },
      })
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
        filters = {
          dotfiles = false,
          git_ignored = false,
          custom = {
            "^\\.venv$", "^venv$",
            "\\.o$", "\\.obj$", "\\.a$", "\\.lib$", "\\.so$", "\\.dylib$", "\\.dll$", "\\.exe$",
            "\\.pyc$", "\\.pyo$", "\\.class$", "\\.jar$",
            "\\.png$", "\\.jpg$", "\\.jpeg$", "\\.gif$", "\\.bmp$", "\\.ico$", "\\.webp$",
            "\\.pdf$", "\\.zip$", "\\.tar$", "\\.gz$", "\\.bz2$", "\\.xz$", "\\.7z$", "\\.rar$",
            "\\.woff$", "\\.woff2$", "\\.ttf$", "\\.eot$",
            "\\.mp3$", "\\.mp4$", "\\.avi$", "\\.mov$", "\\.mkv$",
            "\\.db$", "\\.sqlite$", "\\.sqlite3$",
          },
        },
        git = { enable = true, ignore = false },
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
      -- Indentation is handled by Neovim's built-in filetype indent scripts.
      -- nvim-treesitter's indentexpr over-indents YAML and Python; the shipped
      -- scripts respect shiftwidth and match the file's convention.
      -- Auto-install missing parsers (runs async, won't block startup)
      local ensure = {
          "lua",
          "python",
          "ruby",
          "typescript",
          "rust",
          "cpp",
          "cuda",
          "yaml",
          "json",
          "markdown",
          "markdown_inline",
      }
      local installed = require("nvim-treesitter.config").get_installed("parsers")
      local missing = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
      end, ensure)
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end
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
opt.foldlevel      = 99     -- start with all folds open
opt.foldlevelstart = 99     -- ...for newly opened buffers too

vim.keymap.set("n", "zO", "zR", { desc = "Open all folds" })
vim.keymap.set("n", "zC", "zM", { desc = "Close all folds" })
opt.wrap          = false
opt.modeline      = false
opt.swapfile      = false
opt.number        = true
opt.termguicolors = true
opt.signcolumn    = "yes"   -- always show, avoids layout shifts from LSP diagnostics
opt.autoread      = true    -- auto-reload files changed outside Neovim

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

-- Ctrl-C: copy to system clipboard; disable exit-insert behavior in insert mode
map("v", "<C-c>", '"+y',   { desc = "Copy selection to clipboard" })
map("n", "<C-c>", '"+yy',  { desc = "Copy line to clipboard" })
map("i", "<C-c>", "<Nop>", { desc = "Disabled (use Esc)" })

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
map("n", "<C-p>", "<Cmd>Telescope find_files<CR>")
-- Escape hatch: search EVERYTHING, including deps/build/output dirs normally
-- pruned via .ignore (.venv, eval_results, corridors/target, ...). Slow in big trees.
map("n", "<leader>p", "<Cmd>Telescope find_files find_command=" .. fd_bin .. ",--type,f,--color,never,--hidden,--no-ignore<CR>")
map("n", "<leader>b", "<Cmd>Telescope buffers<CR>")
map("n", "<C-f>", "<Cmd>Telescope live_grep<CR>")
map("n", "<leader>s", "<Cmd>Telescope lsp_document_symbols<CR>") -- functions/classes list

-- aerial (code outline)
map("n", "<leader>a", "<Cmd>AerialToggle!<CR>")

-- Auto-open aerial for Python, YAML, Rust, JS, and TS files. Deferred via
-- vim.schedule so it runs after all other FileType callbacks finish — otherwise
-- AerialOpen shifts focus mid-event and later ftplugin code edits the wrong
-- (aerial) buffer.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "yaml", "rust", "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    local src = vim.api.nvim_get_current_win()
    vim.schedule(function()
      vim.cmd("AerialOpen")
      if vim.api.nvim_win_is_valid(src) then
        vim.api.nvim_set_current_win(src)
      end
    end)
  end,
})

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

-- Auto-reload files changed outside Neovim
local reload_group = vim.api.nvim_create_augroup("AutoReloadFile", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = reload_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" and vim.bo.buftype == "" then
      pcall(vim.cmd, "checktime")
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = reload_group,
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

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
    vim.opt_local.expandtab    = true
    vim.opt_local.textwidth    = 88      -- Black default line length
    vim.opt_local.colorcolumn  = "89"
    vim.opt_local.fileformat   = "unix"
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
  init_options = {
    enabledFeatures = {
      diagnostics = false,
    },
  },
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
      check = { command = "clippy" },
    },
  },
})

vim.lsp.enable({ 'pyright', 'ruff', 'ruby_lsp', 'ts_ls', 'rust_analyzer' })

-- =============================================================================
-- LSP MULTI-FILE EDITS: auto-save the files they touch, and undo them as a unit
-- =============================================================================
-- \rn and multi-file \ca edits apply their changes by loading each affected file
-- as a buffer and editing it in memory, leaving call-site files dirty and easy to
-- miss. Every such edit funnels through vim.lsp.util.apply_workspace_edit -- the
-- textDocument/rename handler, the server-initiated workspace/applyEdit handler,
-- and vim.lsp.buf.code_action all call it -- so wrapping it once covers them all.
-- The wrapper writes every file the edit touched, and records where each buffer's
-- undo history stood either side of it so u / <C-r> can move the edit as a unit
-- instead of leaving the project half-renamed.
local apply_workspace_edit = vim.lsp.util.apply_workspace_edit

-- The most recent multi-file text edit, or nil when there is nothing to move:
-- { entries = { { bufnr, seq_before, seq_after, saved } }, state = "applied"|"undone" }
local last_edit = nil

-- URIs of a workspace edit's text-edit targets. 'rename'/'create'/'delete'
-- documentChanges are skipped: those hit the filesystem directly and leave
-- nothing modified in memory.
local function edited_uris(workspace_edit)
  local uris, seen = {}, {}
  local function add(uri)
    if uri and not seen[uri] then
      seen[uri] = true
      table.insert(uris, uri)
    end
  end
  for _, change in ipairs(workspace_edit.documentChanges or {}) do
    if not change.kind and change.textDocument then
      add(change.textDocument.uri)
    end
  end
  for uri in pairs(workspace_edit.changes or {}) do
    add(uri)
  end
  return uris
end

-- True when an edit carries an explicit file operation. u cannot reverse one, so
-- such an edit is never registered as a group: a partial group undo is worse
-- than none.
local function has_file_ops(workspace_edit)
  for _, change in ipairs(workspace_edit.documentChanges or {}) do
    if change.kind then
      return true
    end
  end
  return false
end

-- Closes a buffer's current undo block so the next change starts a new one.
-- Assigning 'undolevels' is the Lua form of `:let &l:undolevels = &l:undolevels`:
-- the assignment is a no-op and the point is the u_sync() it triggers. Without it
-- an LSP edit can share an undo block with the edit made just before it, and
-- rewinding the edit would silently take that work with it.
local function break_undo(bufnr)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    vim.bo[bufnr].undolevels = vim.bo[bufnr].undolevels
  end
end

-- Whether a URI already pointed at a file with content. An edit can bring a file
-- into existence with no 'create' change of its own: ts_ls "Move to a new file"
-- creates an empty file server-side and then fills it through an ordinary text
-- edit, which over the wire is indistinguishable from a plain two-file edit.
-- Undoing that would leave an empty file behind rather than remove it, so an
-- empty target disqualifies the whole group. Nothing is lost by the check: a file
-- with no content has no symbol in it to rename, so it never takes part in a
-- genuine multi-file rename.
local function has_content(uri)
  local stat = vim.uv.fs_stat(vim.uri_to_fname(uri))
  return stat ~= nil and stat.size > 0
end

-- Undo sequence number a buffer currently sits at; 0 for one not loaded yet,
-- which is where a call-site file the edit is about to open starts from.
local function undo_seq(bufnr)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return 0
  end
  local ok, tree = pcall(vim.fn.undotree, bufnr)
  return ok and tree.seq_cur or 0
end

-- Shortest readable form of a buffer name: relative to cwd when it lives below it.
local function display_name(bufnr)
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
end

-- Joins up to `limit` names, summarizing the remainder as "+N more".
local function name_list(names, limit)
  if #names <= limit then
    return table.concat(names, ", ")
  end
  return table.concat(vim.list_slice(names, 1, limit), ", ")
    .. (", +%d more"):format(#names - limit)
end

-- True when a target buffer still exists as a real file we could write.
local function is_writable_file(bufnr)
  -- A 'delete' change in the same edit -- or the bdelete! that
  -- vim.lsp.util.rename does after its saveas! -- can invalidate a bufnr
  -- collected before the edit was applied.
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_buf_get_name(bufnr) ~= ""
    and vim.bo[bufnr].buftype == ""
end

-- Writes the files that were clean before the edit, noting on each entry whether
-- it reached disk, then reports what was saved, what was left modified, and
-- anything that failed to write.
local function write_edited_bufs(targets)
  local saved_names, skipped_names, failed_names = {}, {}, {}
  for _, entry in ipairs(targets) do
    if is_writable_file(entry.bufnr) and vim.bo[entry.bufnr].modified then
      local name = display_name(entry.bufnr)
      if entry.was_clean then
        -- Autocmds stay on so the servers still get textDocument/didSave.
        local ok = pcall(vim.api.nvim_buf_call, entry.bufnr, function()
          vim.cmd("silent update")
        end)
        entry.saved = ok
        table.insert(ok and saved_names or failed_names, name)
      elseif not entry.is_current then
        table.insert(skipped_names, name)
      end
    end
  end

  if #saved_names > 0 then
    local msg = ("LSP edit: saved %d file%s (%s)")
      :format(#saved_names, #saved_names == 1 and "" or "s", name_list(saved_names, 5))
    if #skipped_names > 0 then
      msg = msg .. (" -- left modified: %s"):format(name_list(skipped_names, 5))
    end
    vim.notify(msg, vim.log.levels.INFO)
  elseif #skipped_names > 0 then
    vim.notify(
      ("LSP edit: left modified, save yourself: %s"):format(name_list(skipped_names, 5)),
      vim.log.levels.INFO
    )
  end

  if #failed_names > 0 then
    vim.notify(
      ("LSP edit: could not write %s"):format(name_list(failed_names, 5)),
      vim.log.levels.WARN
    )
  end
end

-- Remembers the edit as one undoable unit, but only when u could actually move
-- it: nothing created or deleted for undo to reverse, and more than one file
-- changed -- a single-file edit already undoes correctly with a plain u. Always
-- assigns, so a newer edit can never leave a stale group behind.
local function register_group(targets, undoable)
  local entries = {}
  for _, entry in ipairs(targets) do
    if vim.api.nvim_buf_is_valid(entry.bufnr) and entry.seq_after > entry.seq_before then
      table.insert(entries, entry)
    end
  end
  last_edit = (undoable and #entries > 1)
    and { entries = entries, state = "applied" }
    or nil
end

vim.lsp.util.apply_workspace_edit = function(workspace_edit, position_encoding)
  local cur_bufnr = vim.api.nvim_get_current_buf()
  local targets = {}
  for _, uri in ipairs(edited_uris(workspace_edit)) do
    -- Resolve before applying: it is the pre-edit state that decides whether a
    -- file is ours to save and where its undo history stood. vim.uri_to_bufnr is
    -- what the wrapped call uses too, so this creates no buffer it would not have.
    local bufnr = vim.uri_to_bufnr(uri)
    break_undo(bufnr)
    table.insert(targets, {
      bufnr = bufnr,
      -- Never write a file that already held unsaved work. The buffer you are
      -- sitting in shows its own '+' marker, so only report the hidden ones.
      was_clean = not vim.bo[bufnr].modified,
      is_current = bufnr == cur_bufnr,
      seq_before = undo_seq(bufnr),
      pre_existing = has_content(uri),
    })
  end

  apply_workspace_edit(workspace_edit, position_encoding)

  -- Sealed and read synchronously: no keystroke can land inside the edit's undo
  -- block, or move a buffer before its position has been recorded.
  local undoable = not has_file_ops(workspace_edit)
  for _, entry in ipairs(targets) do
    break_undo(entry.bufnr)
    entry.seq_after = undo_seq(entry.bufnr)
    undoable = undoable and entry.pre_existing
  end

  -- Deferred so the writes (and the BufWritePre/Post autocmds that drive
  -- textDocument/didSave) run after the LSP handler has returned.
  vim.schedule(function()
    write_edited_bufs(targets)
    register_group(targets, undoable)
  end)
end

-- True when the recorded edit is still exactly the most recent change in every
-- file it touched, so moving it as a unit cannot clobber anything newer. The
-- current buffer has to be one of them: u should only ever act on the file you
-- are in. A count (3u) always takes the ordinary path.
local function group_ready(state, seq_key)
  if not last_edit or last_edit.state ~= state or vim.v.count ~= 0 then
    return false
  end
  local cur_bufnr = vim.api.nvim_get_current_buf()
  local includes_current = false
  for _, entry in ipairs(last_edit.entries) do
    if not vim.api.nvim_buf_is_valid(entry.bufnr)
      or undo_seq(entry.bufnr) ~= entry[seq_key]
    then
      return false
    end
    includes_current = includes_current or entry.bufnr == cur_bufnr
  end
  return includes_current
end

-- Rewinds (or re-applies) every file in the edit and rewrites the ones we saved.
local function move_group(seq_key, what)
  local moved, failed = {}, {}
  for _, entry in ipairs(last_edit.entries) do
    local name = display_name(entry.bufnr)
    local ok = pcall(vim.api.nvim_buf_call, entry.bufnr, function()
      vim.cmd("silent undo " .. entry[seq_key])
      -- Unconditional, because rewinding can leave 'modified' false while the
      -- buffer no longer matches what we wrote -- :update would skip the file
      -- and the revert would never reach disk. Files deliberately left dirty
      -- are rewound but never written, same policy as the save side.
      if entry.saved and is_writable_file(entry.bufnr) then
        vim.cmd("silent write")
      end
    end)
    table.insert(ok and moved or failed, name)
  end

  if #moved > 0 then
    vim.notify(
      ("LSP %s: %d file%s (%s)")
        :format(what, #moved, #moved == 1 and "" or "s", name_list(moved, 5)),
      vim.log.levels.INFO
    )
  end
  if #failed > 0 then
    vim.notify(
      ("LSP %s: failed on %s"):format(what, name_list(failed, 5)),
      vim.log.levels.WARN
    )
  end
end

-- Hands the keypress back to Vim untouched, count included. Fed rather than run
-- through vim.cmd("normal!") so Vim reports its own errors the way it always
-- does -- E21 in a non-modifiable buffer, "Already at oldest change" at the end
-- of the history -- instead of surfacing a Lua traceback from inside the mapping.
local function feed_stock(key)
  vim.api.nvim_feedkeys(vim.v.count1 .. key, "n", false)
end

-- u and <C-r> move a multi-file edit as a unit while it is still the most recent
-- change in the file you are in; anywhere else they are ordinary undo and redo.
-- So your own edits are always dealt with first, and only once they are undone
-- does u reach the rename underneath them.
map("n", "u", function()
  if group_ready("applied", "seq_after") then
    move_group("seq_before", "undo")
    last_edit.state = "undone"
  else
    feed_stock("u")
  end
end)

map("n", "<C-r>", function()
  if group_ready("undone", "seq_before") then
    move_group("seq_after", "redo")
    last_edit.state = "applied"
  else
    feed_stock(vim.keycode("<C-r>"))
  end
end)

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

