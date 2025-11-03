-- lua/custom/plugins/nvim-jdtls.lua

return {
  'mfussenegger/nvim-jdtls',
  ft = 'java', -- Load this plugin only for Java files
  dependencies = {
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  },
  config = function()
    local jdtls = require 'jdtls'

    -- Function to get Mason install path for a package
    local function get_mason_package_path(package_name)
      local ok, mason_registry = pcall(require, 'mason-registry')
      if not ok then
        vim.notify('mason-registry not available', vim.log.levels.ERROR)
        return nil
      end

      if not mason_registry.is_installed(package_name) then
        vim.notify('Package ' .. package_name .. ' is not installed. Run :MasonInstall ' .. package_name, vim.log.levels.ERROR)
        return nil
      end

      local package = mason_registry.get_package(package_name)
      -- Try different possible methods for getting the install path
      if package.get_install_path then
        return package:get_install_path()
      elseif package.get_installed_path then
        return package:get_installed_path()
      else
        -- Fallback: construct path manually
        local mason_path = vim.fn.stdpath('data') .. '/mason/packages/' .. package_name
        if vim.fn.isdirectory(mason_path) == 1 then
          return mason_path
        else
          vim.notify('Could not determine install path for ' .. package_name, vim.log.levels.ERROR)
          return nil
        end
      end
    end

    -- Get Mason install paths
    local jdtls_path = get_mason_package_path 'jdtls'
    local java_debug_path = get_mason_package_path 'java-debug-adapter'
    local java_test_path = get_mason_package_path 'java-test'

    if not jdtls_path then
      vim.notify('jdtls not found. Please install it via Mason: :MasonInstall jdtls', vim.log.levels.ERROR)
      return
    end

    -- This is the location where jdtls will store its data and downloaded sources.
    local data_dir = vim.fn.stdpath 'data' .. '/jdtls/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

    -- Bundles for debugging and testing (optional)
    local bundles = {}
    if java_debug_path then
      local debug_jar = vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', true)
      if debug_jar ~= '' then
        table.insert(bundles, debug_jar)
      end
    end

    if java_test_path then
      local test_jars = vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar', true), '\n')
      for _, jar in ipairs(test_jars) do
        if jar ~= '' then
          table.insert(bundles, jar)
        end
      end
    end

    -- Find the launcher jar
    local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
    if launcher_jar == '' then
      vim.notify('Could not find Eclipse launcher jar in ' .. jdtls_path, vim.log.levels.ERROR)
      return
    end

    -- Determine OS configuration directory
    local os_config
    if vim.fn.has 'mac' == 1 then
      os_config = 'config_mac'
    elseif vim.fn.has 'unix' == 1 then
      os_config = 'config_linux'
    else
      os_config = 'config_win'
    end

    -- Check for Lombok jar
    local lombok_jar = jdtls_path .. '/lombok.jar'
    local lombok_exists = vim.fn.filereadable(lombok_jar) == 1

    -- Build the command with Lombok support
    local cmd = {
      'java',
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xms1g',
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
    }

    -- Add Lombok agent if available
    if lombok_exists then
      table.insert(cmd, '-javaagent:' .. lombok_jar)
    end

    -- Add the jar and configuration
    vim.list_extend(cmd, {
      '-jar',
      launcher_jar,
      '-configuration',
      jdtls_path .. '/' .. os_config,
      '-data',
      data_dir,
    })

    local config = {
      -- The command to start the language server
      cmd = cmd,

      -- This tells jdtls where to find the project root
      root_dir = require('jdtls.setup').find_root { 'gradlew', 'mvnw', '.git', 'pom.xml', 'build.gradle' },

      -- Pass the bundles to jdtls
      init_options = {
        bundles = bundles,
      },

      -- Here you could add the on_attach function if needed
      on_attach = function(client, bufnr)
        -- Standard LSP keymaps are handled by the main LSP config
        -- Add any jdtls-specific keymaps here if needed
        jdtls.setup_dap { hotcodereplace = 'auto' }
      end,

      -- Capabilities from blink.cmp
      capabilities = require('blink.cmp').get_lsp_capabilities(),
    }

    -- Start the language server
    jdtls.start_or_attach(config)
  end,
}
