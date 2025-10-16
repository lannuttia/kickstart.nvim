-- in your init.lua or a dedicated plugin file
return {
  'bearded-giant/plantuml.nvim',
  -- optional: configure renderers or other settings here
  config = function()
    require('plantuml').setup {
      renderer = {
        type = 'imv',
        options = {
          dark_mode = true,
          format = nil,
        },
      },
      render_on_write = true,
    }
  end,
}
