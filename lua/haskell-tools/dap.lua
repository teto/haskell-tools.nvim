local ht = require('haskell-tools')
local deps = require('haskell-tools.deps')
local project_util = require('haskell-tools.project-util')

local M = {
  build_configurations = function(...) end,
}

local function get_ghci_cmd(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if project_util.is_cabal_project(path) then 
    return 'cabal v2-exec -- ghci-dap --interactive -i ${workspaceFolder}'
  else 
    return 'stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show'
  end
end

local function setup_dap(dap)
  M.dap = dap;
  local opts = ht.config.options
  local dap_opts = opts.dap
  dap.adapters.ghc = {
    type = 'executable',
    command = 'haskell-debug-adapter',
    args = { '--hackage-version=' .. dap_opts.hackageVersion },
  }

  function M.build_configurations(bufnr)
    bufnr = bufnr or 0 -- Default to current buffer
    dap.configurations.haskell = {
      -- TODO: Parse hie.yaml to generate configs
      {
        type = 'ghc',
        request = 'launch',
        name = 'haskell-debug-adapter',
        internalConsoleOptions = 'openOnSessionStart',
        workspace = '${workspaceFolder}',
        startup = '${workspaceFolder}/app/Main.hs',
        startupFunc = '',
        startupArgs = '';
        stopOnEntry = false,
        mainArgs = '';
        logFile = dap_opts.logFile,
        logLevel = 'DEBUG',
        ghciEnv = vim.empty_dict(),
        ghciPrompt = 'λ: ',
        ghciInitialPrompt = 'ghci> ',
        ghciCmd = get_ghci_cmd(bufnr),
        forceInspect = false,
      },
    }
end

end

function M.setup()
  deps.if_available('dap', setup_dap)
end

return M
