-- leader keybinds
vim.g.mapleader = ','
vim.g.maplocalleader = ','
-- leader twice to switch back and forth last opened file
vim.keymap.set('n', '<leader><leader>', '<c-^>', { noremap = true })
-- leader + sf to splti vertically to last opened file
vim.keymap.set('n', '<leader>sf', ':vert sf #<CR>', { noremap = true })
-- Tab to go to next buffer
vim.keymap.set('n', '<Tab>', vim.cmd.bnext)
-- Shift + Tab to go to previous buffer
vim.keymap.set('n', '<S-Tab>', vim.cmd.bprevious)
-- leader + v to open new vertical split and switch to it
-- TODO: Consider ":vs ." and ":sp ." instead?
vim.keymap.set('n', '<leader>v', vim.cmd.vs, { noremap = true })
-- leader + h to open new horizontal split and switch to it
vim.keymap.set('n', '<leader>h', vim.cmd.sp, { noremap = true })
-- leader + b for quick buffer switching (custom fzf overrides this)
vim.keymap.set('n', '<leader>b', ':b <C-z>', { noremap = true })
-- leader + e for quick file switching (custom fzf overrides this)
vim.keymap.set('n', '<leader>e', ':e <C-z>', { noremap = true })
-- Esc twice clears search highlight
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch <CR>', {noremap = true, silent = true})
-- leader + q to smart close: buffer if >1 buffer, else quit
vim.keymap.set('n', '<leader>q', function()
  local buffers = vim.fn.getbufinfo({buflisted = 1})
  if #buffers > 1 then
    vim.cmd('bd')
  else
    vim.cmd('q')
  end
end, { noremap = true, silent = true })

-- spanish layout mappings
vim.keymap.set('n', 'ñ', ';')
vim.keymap.set('n', 'Ñ', ':')
vim.keymap.set('n', '°', '~')
-- Move up/down by visual lines, not file lines
vim.keymap.set('n', 'j', 'gj', { noremap = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true })
-- Next instance of exact word
vim.keymap.set('n', 'gw', '*n')
-- minus sign goes to outer or matching bracket
vim.keymap.set('n', '-', '%', { noremap = true })
-- Moving around splits with Ctrl+dir...
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true })
 -- or Alt+arrow keys
vim.keymap.set('n', '<A-left>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<A-down>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<A-up>', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<A-right>', '<C-w>l', { noremap = true })
-- resize with Ctrl + arrows
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { noremap = true, silent = true })
-- move lines in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
-- stay indenting
vim.keymap.set('v', '<', '<gv', { noremap = true, silent = true })
vim.keymap.set('v', '>', '>gv', { noremap = true, silent = true })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

--
-- Smart Tab
-- (insert) Tab autocompletes if it can't indent
-- (insert) Shift+Tab cycles autocomplete backwards if active
local function smart_tab()
	if vim.fn.pumvisible() == 1 then
		return '<C-n>'          -- cycle next item
	end
	local col = vim.fn.col('.') - 1
	if col == 0 or vim.fn.getline('.'):sub(1, col):match('^%s*$') then
		return '\t'             -- indent at BOL/whitespace
	else
		return '<C-x><C-o>'     -- trigger omni completion
	end
end
vim.keymap.set('i', '<Tab>', smart_tab, { expr = true, noremap = true })
vim.keymap.set('i', '<S-Tab>', function()
	return vim.fn.pumvisible() == 1 and '<C-d>'
end, { expr = true, noremap = true })
