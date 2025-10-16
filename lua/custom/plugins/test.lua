return {
  'vim-test/vim-test',
  dependencies = {
    'preservim/vimux', -- Optional: for tmux integration
  },
  config = function()
    -- Sets the test runner strategy. 'neovim' uses a terminal buffer.
    vim.g['test#strategy'] = 'dispatch'

    -- It's highly recommended to set up keymaps for convenience.
    vim.keymap.set('n', '<leader>tn', ':TestNearest<CR>', { desc = 'Test Nearest' })
    vim.keymap.set('n', '<leader>tf', ':TestFile<CR>', { desc = 'Test File' })
    vim.keymap.set('n', '<leader>ts', ':TestSuite<CR>', { desc = 'Test Suite' })
    vim.keymap.set('n', '<leader>tl', ':TestLast<CR>', { desc = 'Test Last' })
    vim.keymap.set('n', '<leader>tg', ':TestVisit<CR>', { desc = 'Go to test file' })
  end,
}
