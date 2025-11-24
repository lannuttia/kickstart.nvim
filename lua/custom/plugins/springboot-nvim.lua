return {
  'elmcgill/springboot-nvim',
  ft = 'java',
  dependencies = {
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-jdtls',
    'folke/which-key.nvim',
  },
  config = function()
    local springboot_nvim = require 'springboot-nvim'
    local wc = require 'which-key'
    wc.add { '<leader>j', group = '[J]ava' }
    wc.add { '<leader>js', group = '[J]ava [S]pring Boot' }
    wc.add { '<leader>jc', group = '[J]ava [C]reate' }
    vim.keymap.set('n', '<leader>jsr', springboot_nvim.boot_run, { desc = '[J]ava [S]pring Boot [R]un' })
    vim.keymap.set('n', '<leader>jcc', springboot_nvim.generate_class, { desc = '[J]ava [C]reate [C]lass' })
    vim.keymap.set('n', '<leader>jci', springboot_nvim.generate_interface, { desc = '[J]ava [C]reate [I]nterface' })
    vim.keymap.set('n', '<leader>jce', springboot_nvim.generate_enum, { desc = '[J]ava [C]reate [E]num' })
    springboot_nvim.setup {}
  end,
}
