-- Java Development Tools Language Server
return {
  'mfussenegger/nvim-jdtls',
  ft = { 'java' },
  config = function()
    -- Set up keymaps when jdtls is attached (only once)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('jdtls-lsp-attach', { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == 'jdtls' then
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = args.buf, desc = 'Java: ' .. desc })
          end

          -- Java specific LSP actions (extended JDTLS features)
          map('gro', require('jdtls').organize_imports, '[O]rganize imports')
          map('grv', require('jdtls').extract_variable, 'Extract [v]ariable')
          map('grc', require('jdtls').extract_constant, 'Extract [c]onstant')
          map('gru', '<cmd>JdtUpdateConfig<CR>', '[U]pdate config')

          -- Java test actions
          map('<leader>Tm', require('jdtls').test_nearest_method, '[T]est nearest [m]ethod')
          map('<leader>Tc', require('jdtls').test_class, '[T]est [c]lass')

          -- Extract method in visual mode
          map('grm', "<esc><cmd>lua require('jdtls').extract_method(true)<cr>", 'Extract [m]ethod', 'v')
        end
      end,
    })

    -- Set up autocmd to start/attach JDTLS only when opening Java files
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('jdtls-setup', { clear = true }),
      pattern = 'java',
      callback = function()
        local jdtls = require 'jdtls'

        -- Find the root of the project
        local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
        local root_dir = require('jdtls.setup').find_root(root_markers)

        -- Use an existing workspace directory or create a new one based on the project name
        local workspace_dir = vim.fn.stdpath 'data' .. '/workspace/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

        -- Build the bundles table for debug and test support
        local bundles = {}

        -- Add java-debug-adapter
        local debug_jar = vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true)
        if debug_jar ~= '' then table.insert(bundles, debug_jar) end

        -- Add java-test plugin (all JARs required for test resolution)
        local java_test_jars = vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/packages/java-test/extension/server/*.jar', true)
        if java_test_jars ~= '' then
          vim.list_extend(bundles, vim.split(java_test_jars, '\n'))
        end

        -- Get lombok javaagent from environment variable if available
        local jvm_args = {}
        local jdtls_jvm_args = vim.env.JDTLS_JVM_ARGS
        if jdtls_jvm_args and jdtls_jvm_args ~= '' then
          -- Split the JVM args by space and add them to our args table
          for arg in jdtls_jvm_args:gmatch('%S+') do
            table.insert(jvm_args, arg)
          end
        end

        local config = {
          -- The command that starts the language server
          cmd = vim.tbl_flatten({
            'java',

            jvm_args, -- Include lombok javaagent and other JVM args

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

            -- The jar file is located where jdtls was installed via Mason
            '-jar',
            vim.fn.glob(vim.fn.stdpath 'data' .. '/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),

            -- The configuration directory (Linux)
            '-configuration',
            vim.fn.stdpath 'data' .. '/mason/packages/jdtls/config_linux',

            -- The workspace directory
            '-data',
            workspace_dir,
          }),

          -- This is the default if not provided, you can remove it. Or adjust as needed.
          -- One dedicated LSP server & client will be started per unique root_dir
          root_dir = root_dir,

          -- Here you can configure eclipse.jdt.ls specific settings
          settings = {
            java = {
              -- Enable/disable the 'auto build'
              autobuild = { enabled = false },
              -- Enable/disable downloading of Maven dependencies
              maven = { downloadSources = true },
              -- Enable/disable downloading of Gradle dependencies
              gradle = { downloadSources = true },
              -- Use the fernflower decompiler when browsing external dependencies
              contentProvider = { preferred = 'fernflower' },
            },
          },

          -- Language server `initializationOptions`
          -- You need to extend the `bundles` with paths to jar files
          -- if you want to use additional eclipse.jdt.ls plugins.
          init_options = {
            bundles = bundles,
          },
        }

        -- This starts a new client & server,
        -- or attaches to an existing client & server depending on the `root_dir`.
        jdtls.start_or_attach(config)
      end,
    })
  end,
}

