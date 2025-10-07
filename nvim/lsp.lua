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
