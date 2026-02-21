-- spec/support/vim_stub.lua
-- Minimal vim-API stub for running terminal tests outside Neovim.

local vim_stub = {
  tbl_deep_extend = function(mode, ...)
    local result = {}
    local function deep_extend(t)
      for k, v in pairs(t) do
        if type(v) == "table" and type(result[k]) == "table" then
          local sub = {}
          for kk, vv in pairs(result[k]) do sub[kk] = vv end
          for kk, vv in pairs(v) do
            if type(vv) == "table" and type(sub[kk]) == "table" then
              local subsub = {}
              for kkk, vvv in pairs(sub[kk]) do subsub[kkk] = vvv end
              for kkk, vvv in pairs(vv) do subsub[kkk] = vvv end
              sub[kk] = subsub
            else
              sub[kk] = vv
            end
          end
          result[k] = sub
        else
          result[k] = v
        end
      end
    end
    for i = 1, select("#", ...) do
      local t = select(i, ...)
      if t then deep_extend(t) end
    end
    return result
  end,

  fn = {
    stdpath = function(what) return "/tmp/terminal_test_" .. what end,
    expand = function(s) return "/tmp/test_file.lua" end,
    win_getid = function() return 0 end,
    getcwd = function() return "/tmp" end,
    termopen = function() return 1 end,
  },

  api = {
    nvim_set_hl = function() end,
    nvim_get_hl = function() return {} end,
    nvim_create_autocmd = function() end,
    nvim_create_buf = function() return 1 end,
    nvim_open_win = function() return 1 end,
    nvim_win_is_valid = function() return false end,
    nvim_buf_is_valid = function() return false end,
    nvim_win_hide = function() end,
    nvim_set_current_win = function() end,
    nvim_command = function() end,
    nvim_win_get_height = function() return 20 end,
    nvim_win_get_width = function() return 80 end,
    nvim_chan_send = function() end,
  },

  keymap = {
    del = function() end,
  },

  cmd = function() end,

  notify = function() end,

  bo = {
    filetype = "lua",
  },

  o = {
    lines = 24,
    columns = 80,
    shell = "/bin/bash",
  },

  b = setmetatable({}, {
    __index = function() return { terminal_job_id = 1 } end,
  }),

  lsp = {
    get_clients = function() return {} end,
  },

  log = {
    levels = { ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 },
  },

  _commands = {},
  _keymaps = {},
}

-- These closures reference vim_stub, so they must be defined after the table exists.
vim_stub.api.nvim_create_user_command = function(name, fn, opts)
  vim_stub._commands[name] = { fn = fn, opts = opts }
end

vim_stub.keymap.set = function(mode, lhs, rhs, opts)
  table.insert(vim_stub._keymaps, { mode = mode, lhs = lhs })
end

return vim_stub
