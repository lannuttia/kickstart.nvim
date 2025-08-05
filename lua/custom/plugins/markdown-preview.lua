return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = function()
    vim.fn['mkdp#util#install']()
  end,
  init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
    vim.g.mkdp_browser = 'firefox'
  end,
  ft = { 'markdown' },
  config = function()
    vim.api.nvim_set_keymap('n', '<leader>mp', ':MarkdownPreview<CR>', { noremap = true, silent = true, desc = 'Start Markdown Live Preview' })
  end,
}
