return {
  'coder/claudecode.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('claudecode').setup {
      -- Uses your existing Claude Code configuration automatically
      -- Environment variables detected:
      -- CLAUDE_CODE_USE_VERTEX=1
      -- ANTHROPIC_VERTEX_PROJECT_ID=itpc-gcp-it-all-claude
      -- CLOUD_ML_REGION=us-east5
      -- ANTHROPIC_MODEL=claude-sonnet-4@20250514

      -- Start integration automatically when Neovim starts
      auto_start = true,

      -- Focus terminal after sending code
      focus_after_send = false,

      -- Track selection changes (useful for context)
      track_selection = true,

      -- Terminal configuration
      terminal = {
        -- Use your existing Claude Code setup
        terminal_cmd = 'claude',
      },
    }

    -- Show notification that Claude Code is ready
    vim.notify('Claude Code integration loaded! Use <leader>at to toggle terminal.', vim.log.levels.INFO)
  end,
  keys = {
    { '<leader>at', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude Code Terminal' },
    { '<leader>ac', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude Code Terminal' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send Selection to Claude' },
    { '<leader>aa', '<cmd>ClaudeCodeSend<cr>', desc = 'Send Current File to Claude' },
    { '<leader>ao', '<cmd>ClaudeCodeOpen<cr>', desc = 'Open Claude Code Terminal' },
    { '<leader>ax', '<cmd>ClaudeCodeClose<cr>', desc = 'Close Claude Code Terminal' },
    { '<leader>ai', '<cmd>ClaudeCodeStatus<cr>', desc = 'Claude Code Status' },
  },
  event = { 'BufReadPost', 'BufNewFile' },
}

