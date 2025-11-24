-- nvim-jdtls.lua
-- Enhanced Java LSP support using nvim-jdtls with native LSP configuration

return {
  'mfussenegger/nvim-jdtls',
  ft = 'java',
  dependencies = {
    'mfussenegger/nvim-dap',
    'folke/which-key.nvim',
  },
  config = function()
    local jdtls = require 'jdtls'
    local path = require 'jdtls.path'

    -- Function to get the jdtls installation directory
    local function get_jdtls_install_dir()
      -- Try Mason installation first - use direct path since registry API changed
      local mason_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
      if vim.fn.isdirectory(mason_path) == 1 then
        return mason_path
      end

      -- Fallback to common installation paths
      local common_paths = {
        vim.fn.expand '~/.local/share/nvim/mason/packages/jdtls',
        '/usr/share/java/jdtls',
        '/opt/jdtls',
      }

      for _, path_dir in ipairs(common_paths) do
        if vim.fn.isdirectory(path_dir) == 1 then
          return path_dir
        end
      end

      error 'jdtls not found. Please install it via Mason (:Mason) or manually'
    end

    -- Function to find the jdtls jar file
    local function get_jdtls_jar()
      local install_dir = get_jdtls_install_dir()
      local jar_patterns = {
        install_dir .. '/plugins/org.eclipse.equinox.launcher_*.jar',
      }

      for _, pattern in ipairs(jar_patterns) do
        local jars = vim.fn.glob(pattern, false, true)
        if #jars > 0 then
          return jars[1]
        end
      end

      error('jdtls launcher jar not found in ' .. install_dir)
    end

    -- Function to get workspace dir
    local function get_workspace_dir()
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace_dir = vim.fn.expand '~/.local/share/nvim/jdtls-workspace/' .. project_name
      return workspace_dir
    end

    -- Function to get the configuration directory
    local function get_config_dir()
      local install_dir = get_jdtls_install_dir()
      local os_name = vim.loop.os_uname().sysname:lower()

      if os_name:find 'linux' then
        return install_dir .. '/config_linux'
      elseif os_name:find 'darwin' then
        return install_dir .. '/config_mac'
      elseif os_name:find 'windows' then
        return install_dir .. '/config_win'
      else
        return install_dir .. '/config_linux' -- fallback
      end
    end

    -- Function to get Java executable
    local function get_java_executable()
      -- Check for JAVA_HOME
      if vim.env.JAVA_HOME then
        local java_path = path.join(vim.env.JAVA_HOME, 'bin', 'java')
        if vim.fn.executable(java_path) == 1 then
          return java_path
        end
      end

      -- Check for java in PATH
      if vim.fn.executable 'java' == 1 then
        return 'java'
      end

      error 'Java executable not found. Please install Java and set JAVA_HOME or add java to PATH'
    end

    -- Function to get debug bundles
    local function get_debug_bundles()
      local bundles = {}

      -- Add java-debug-adapter - use direct path since registry API changed
      local java_debug_path = vim.fn.stdpath 'data' .. '/mason/packages/java-debug-adapter'
      if vim.fn.isdirectory(java_debug_path) == 1 then
        local debug_jar = vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar')
        if debug_jar ~= '' then
          table.insert(bundles, debug_jar)
        end
      end

      -- Add java-test
      local java_test_path = vim.fn.stdpath 'data' .. '/mason/packages/java-test'
      if vim.fn.isdirectory(java_test_path) == 1 then
        vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar'), '\n'))
      end

      return bundles
    end

    -- Function to build jdtls command with optional JVM args
    local function build_jdtls_cmd()
      local cmd = {
        get_java_executable(),
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xms1g',
        '-Xmx2G',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
      }

      -- Add custom JVM args from environment variable if set
      if vim.env.JDTLS_JVM_ARGS then
        local custom_args = vim.split(vim.env.JDTLS_JVM_ARGS, '%s+')
        for _, arg in ipairs(custom_args) do
          if arg ~= '' then -- Skip empty strings
            table.insert(cmd, arg)
          end
        end
      end

      -- Add the jar and configuration at the end
      table.insert(cmd, '-jar')
      table.insert(cmd, get_jdtls_jar())
      table.insert(cmd, '-configuration')
      table.insert(cmd, get_config_dir())
      table.insert(cmd, '-data')
      table.insert(cmd, get_workspace_dir())

      return cmd
    end

    -- Configure jdtls using vim.lsp.config
    vim.lsp.config('jdtls', {
      cmd = build_jdtls_cmd(),
      root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },
      filetypes = { 'java' },
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
          inlayHints = {
            parameterNames = {
              enabled = 'all', -- literals, all, none
            },
          },
          format = {
            enabled = false, -- Use conform.nvim for formatting instead
          },
        },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.hamcrest.CoreMatchers.*',
            'org.junit.jupiter.api.Assertions.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
            'org.mockito.Mockito.*',
          },
        },
        contentProvider = { preferred = 'fernflower' },
        extendedClientCapabilities = jdtls.extendedClientCapabilities,
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
          },
          useBlocks = true,
        },
      },

      init_options = {
        bundles = get_debug_bundles(),
      },

      on_attach = function(client, bufnr)
        local wc = require 'which-key'
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- LSP keybindings (same as other LSPs)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
        map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

        wc.add { '<leader>j', group = '[J]ava' }

        -- Java specific keymaps
        map('<leader>jo', jdtls.organize_imports, '[J]ava [O]rganize Imports')

        wc.add { '<leader>je', group = '[J]ava [E]xtract' }
        map('<leader>jev', jdtls.extract_variable, '[J]ava [E]xtract [V]ariable')
        map('<leader>jec', jdtls.extract_constant, '[J]ava [E]xtract [C]onstant')
        map('<leader>jem', jdtls.extract_method, '[J]ava [E]xtract [M]ethod', { 'n', 'v' })

        -- Test keymaps
        wc.add { '<leader>jt', group = '[J]ava [T]est' }
        map('<leader>jtc', jdtls.test_class, '[J]ava [T]est [C]lass')
        map('<leader>jtm', jdtls.test_nearest_method, '[J]ava [T]est [M]ethod')

        -- Apply inlay hint toggle if supported
        if client.supports_method 'textDocument/inlayHint' then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })
  end,
}
