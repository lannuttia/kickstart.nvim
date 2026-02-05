return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = { 'markdown' },
  build = 'cd app && npm install',
  init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
  config = function()
    -- Optional: Add configuration options here
  end,
}
