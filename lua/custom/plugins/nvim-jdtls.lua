return {
  'mfussenegger/nvim-jdtls',
  ft = 'java',
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  config = function()
    local jdtls = require 'jdtls'

    -- Find root of project
    local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
    local root_dir = require('jdtls.setup').find_root(root_markers)
    if root_dir == '' then
      return
    end

    -- Path to Mason's jdtls installation
    local mason_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
    local launcher_jar = vim.fn.glob(mason_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

    -- Check if jdtls is properly installed
    if launcher_jar == '' then
      vim.notify('jdtls not found. Please run :MasonInstall jdtls', vim.log.levels.WARN)
      return
    end

    local extendedClientCapabilities = jdtls.extendedClientCapabilities
    extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = vim.fn.stdpath 'data' .. '/site/java/workspace-root/' .. project_name
    os.execute('mkdir -p ' .. workspace_dir)

    -- Determine Java executable
    local java_cmd = vim.fn.exepath 'java'
    if java_cmd == '' then
      vim.notify('Java not found in PATH', vim.log.levels.ERROR)
      return
    end

    -- Find debug bundles
    local bundles = {}

    -- Java Debug Server (com.microsoft.java.debug.plugin)
    local java_debug_path = vim.fn.stdpath 'data' .. '/mason/packages/java-debug-adapter'
    local java_debug_jar = vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar')
    if java_debug_jar ~= '' then
      table.insert(bundles, java_debug_jar)
    end

    -- VSCode Java Test (vscode-java-test)
    local java_test_path = vim.fn.stdpath 'data' .. '/mason/packages/java-test'
    local java_test_jars = vim.fn.glob(java_test_path .. '/extension/server/*.jar', true, true)
    for _, jar in ipairs(java_test_jars) do
      table.insert(bundles, jar)
    end

    -- Main jdtls config
    local config = {
      cmd = {
        java_cmd,
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '-jar',
        launcher_jar,
        '-configuration',
        mason_path .. '/config_linux',
        '-data',
        workspace_dir,
      },
      root_dir = root_dir,
      capabilities = require('blink.cmp').get_lsp_capabilities(),
      settings = {
        java = {
          eclipse = {
            downloadSources = true,
          },
          configuration = {
            updateBuildConfiguration = 'interactive',
          },
          maven = {
            downloadSources = true,
          },
          implementationsCodeLens = {
            enabled = true,
          },
          referencesCodeLens = {
            enabled = true,
          },
          references = {
            includeDecompiledSources = true,
          },
          format = {
            enabled = true,
          },
        },
        signatureHelp = { enabled = true },
        extendedClientCapabilities = extendedClientCapabilities,
      },
      init_options = {
        bundles = bundles,
      },
      on_attach = function(client, bufnr)
        -- Setup nvim-dap for Java
        require('jdtls').setup_dap { hotcodereplace = 'auto' }
        require('jdtls.dap').setup_dap_main_class_configs()

        -- Optional: Setup which-key mappings for Java-specific commands
        local wk = require 'which-key'
        wk.add {
          { '<leader>j', group = '[J]ava', buffer = bufnr },
          {
            '<leader>jo',
            function()
              require('jdtls').organize_imports()
            end,
            desc = '[O]rganize Imports',
            buffer = bufnr,
          },
          {
            '<leader>jv',
            function()
              require('jdtls').extract_variable()
            end,
            desc = 'Extract [V]ariable',
            buffer = bufnr,
          },
          {
            '<leader>jc',
            function()
              require('jdtls').extract_constant()
            end,
            desc = 'Extract [C]onstant',
            buffer = bufnr,
          },
          {
            '<leader>jm',
            function()
              require('jdtls').extract_method(true)
            end,
            desc = 'Extract [M]ethod',
            buffer = bufnr,
          },
          {
            '<leader>jt',
            function()
              require('jdtls').test_nearest_method()
            end,
            desc = '[T]est Method',
            buffer = bufnr,
          },
          {
            '<leader>jT',
            function()
              require('jdtls').test_class()
            end,
            desc = '[T]est Class',
            buffer = bufnr,
          },
        }
      end,
    }

    -- Start jdtls
    require('jdtls').start_or_attach(config)
  end,
}

