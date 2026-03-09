return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
  ft = { 'markdown' },
  build = 'cd app && npm install',
  init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
  config = function()
    -- Browser to open preview (use default browser)
    vim.g.mkdp_browser = ''

    -- Auto start preview when opening markdown files (set to 0 to disable)
    vim.g.mkdp_auto_start = 0

    -- Auto close preview when switching from markdown buffer (set to 0 to disable)
    vim.g.mkdp_auto_close = 1

    -- Refresh preview on save only (set to 0 for real-time updates)
    vim.g.mkdp_refresh_slow = 0

    -- Preview server port (empty for random)
    vim.g.mkdp_port = ''

    -- Enable GitHub-flavored markdown (tables, strikethrough, etc.)
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = 'middle',
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {},
    }

    -- Custom CSS for preview (empty for default)
    vim.g.mkdp_markdown_css = ''

    -- Keybindings for markdown files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function()
        local opts = { buffer = true, silent = true }
        vim.keymap.set('n', '<leader>mp', ':MarkdownPreview<CR>', vim.tbl_extend('force', opts, { desc = '[M]arkdown [P]review' }))
        vim.keymap.set('n', '<leader>ms', ':MarkdownPreviewStop<CR>', vim.tbl_extend('force', opts, { desc = '[M]arkdown preview [S]top' }))
        vim.keymap.set('n', '<leader>mt', ':MarkdownPreviewToggle<CR>', vim.tbl_extend('force', opts, { desc = '[M]arkdown preview [T]oggle' }))
      end,
    })
  end,
}
