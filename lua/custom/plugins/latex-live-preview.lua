return {
  'xuhdev/vim-latex-live-preview',
  build = 'npm install -g neovim', -- This is often needed for some features
  ft = { 'tex' }, -- Only load for LaTeX files
  cmd = { 'LatexLivePreview', 'LatexLivePreviewStop' }, -- Commands it provides
  init = function()
    vim.g.livepreview_previewer = 'zathura'
  end,
  config = function()
    vim.api.nvim_set_keymap('n', '<leader>lp', ':LLPStartPreview<CR>', { noremap = true, silent = true, desc = 'Start LaTeX Live Preview' })
  end,
}
