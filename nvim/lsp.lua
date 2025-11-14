-- TODO: v0.12.x. Installed manually for now
-- vim.pack.add({
-- 	{ src = 'https://github.com/neovim/nvim-lspconfig/', version = 'e688b48' },
-- })

-- ════════════════════ Ruby ════════════════════

vim.lsp.enable('ruby_lsp')

-- ═══════════════════ Python ═══════════════════

vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      analysis = {
        useLibraryCodeForTypes = true,
        autoImportCompletion = true,
      },
      disableOrganizeImports = true,
    }
  }
})
vim.lsp.config('ruff', {
  init_options = {
    settings = {
      fixAll = true,
      organizeImports = true,
      lint = {
        enable = true,
      },
    }
  }
})
vim.lsp.enable({'basedpyright', 'ruff'})

-- ═════════════════════ Go ═════════════════════

vim.lsp.enable('gopls')

-- ════════════════════ YAML ════════════════════

vim.lsp.enable('yamlls')


--═══════════════════ Keymaps ═══════════════════

vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
-- Also <C-w>d
-- KK also focuses it, so it's easy to close with just "q"
vim.keymap.set('n', 'K', vim.diagnostic.open_float, {})
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
vim.keymap.set('n', '<C-s>', vim.lsp.buf.signature_help, {})
-- grr -> vim.lsp.buf.references()
-- [q, ]q, [Q, ]Q to navigate quickfix
-- https://neovim.io/doc/user/lsp.html#vim.lsp.foldexpr()
-- ]d jumps to the next diagnostic in the buffer. ]d-default
-- [d jumps to the previous diagnostic in the buffer. [d-default
-- ]D jumps to the last diagnostic in the buffer. ]D-default
-- [D jumps to the first diagnostic in the buffer. [D-default
-- <C-w>d shows diagnostic at cursor in a floating window. CTRL-W_d-default
