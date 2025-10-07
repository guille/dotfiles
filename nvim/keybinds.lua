-- leader keybinds
vim.g.mapleader = ','
vim.g.maplocalleader = ','
vim.keymap.set('n', '<leader><leader>', '<c-^>', { noremap = true, desc = 'Switch to last opened file' })
vim.keymap.set('n', '<leader>sf', ':vert sf #<CR>', { noremap = true, desc = 'Split vertically to last opened file' })
vim.keymap.set('n', '<Tab>', vim.cmd.bnext, { desc = 'Go to next buffer' })
vim.keymap.set('n', '<S-Tab>', vim.cmd.bprevious, { desc = 'Go to previous buffer' })
-- TODO: Consider ":vs ." and ":sp ." instead?
vim.keymap.set('n', '<leader>v', vim.cmd.vs, { noremap = true, desc = 'Open new vertical split and focus it' })
vim.keymap.set('n', '<leader>h', vim.cmd.sp, { noremap = true, desc = 'Open new horizontal split and focus it' })
vim.keymap.set('n', '<leader>m', 'gcc', { remap = true, desc = 'Comment/uncomment line' })
vim.keymap.set('v', '<leader>m', 'gc', { remap = true, desc = 'Comment/uncomment selection' })
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch <CR>', {noremap = true, silent = true, desc = 'Clear search highlight'})
vim.keymap.set('n', '<leader>q', function()
  local buffers = vim.fn.getbufinfo({buflisted = 1})
  if #buffers > 1 then
    vim.cmd('bd')
  else
    vim.cmd('q')
  end
end, { noremap = true, silent = true, desc = 'Smart close (buffer if multiple buffers open, otherwise quit)' })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set('n', 'k', 'gk', { noremap = true, desc = 'Move up by visual lines' })
vim.keymap.set('n', 'j', 'gj', { noremap = true, desc = 'Move down by visual lines' })
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

vim.keymap.set('n', '<Esc>', function()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == 'win' then
      vim.api.nvim_win_close(win, false)
    end
  end
end)


-- spanish layout mappings
vim.keymap.set('n', 'ñ', ';')
vim.keymap.set('n', 'Ñ', ':')
vim.keymap.set('n', '°', '~')

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
