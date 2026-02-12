return {
  'nickjvandyke/opencode.nvim',
  dependencies = {
    { 'folke/snacks.nvim', opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {}

    -- Required for auto-reloading buffers changed by opencode
    vim.o.autoread = true

    -- Keymaps using <leader>a prefix for AI commands
    vim.keymap.set({ 'n', 't' }, '<leader>at', function() require('opencode').toggle() end, { desc = 'Toggle OpenCode' })
    vim.keymap.set({ 'n', 'x' }, '<leader>aa', function() require('opencode').ask('@this: ', { submit = true }) end, { desc = 'Ask OpenCode' })
    vim.keymap.set({ 'n', 'x' }, '<leader>as', function() require('opencode').select() end, { desc = 'OpenCode Actions' })
    vim.keymap.set({ 'n', 'x' }, '<leader>ao', function() return require('opencode').operator '@this ' end, { desc = 'Add range to OpenCode', expr = true })
    vim.keymap.set('n', '<leader>aO', function() return require('opencode').operator('@this ') .. '_' end, { desc = 'Add line to OpenCode', expr = true })
  end,
  event = { 'BufReadPost', 'BufNewFile' },
}
