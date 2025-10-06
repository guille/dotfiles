-- print the line number in front of each line
vim.o.number = true
vim.o.signcolumn = "yes"

-- minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 4

-- case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- highlight the line where the cursor is on
vim.o.cursorline = true

-- soft wrapping
vim.o.linebreak = true

-- new vertical split goes below the current one
-- new horizontal split goes to the right
vim.o.splitbelow = true
vim.o.splitright = true

-- ruler at 100 chars
vim.o.colorcolumn="100"

-- complete (kinda) like zsh
vim.o.wildmode = "longest:full,list:full"
vim.o.wildignorecase = true
vim.o.completeopt = "menuone,longest,noselect,fuzzy"

-- subtitute globally by default
vim.o.gdefault = true

-- no .swp files
vim.o.swapfile = false

-- default: hard tabs with size of 4
vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

-- enable rendering of whitespace and tabs
vim.o.list = true
vim.o.listchars = "tab:▸ ,space:·"

-- borders for popups disabled (fzf has its own)
vim.o.winborder = "rounded"

-- will add it to statusline instead
vim.o.showmode = false

-- swap is disabled so this is just for CursorHold event triggers, which some plugins use to reload?
vim.o.updatetime = 1000
