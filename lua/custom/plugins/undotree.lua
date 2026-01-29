return {
  'jiaoshijie/undotree',
  dependencies = 'nvim-lua/plenary.nvim',
  config = true,
  keys = { -- load the plugin only when using it's keybinding:
    { '<leader>tu', "<cmd>lua require('undotree').toggle()<cr>", desc = '[T]oggle [U]ndotree' },
  },
}
