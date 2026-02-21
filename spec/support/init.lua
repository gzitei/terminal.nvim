-- spec/support/init.lua
-- Bootstrap: make terminal modules resolvable and inject the vim stub.

local root = debug.getinfo(1, "S").source:match("^@(.+)/spec/support/init%.lua$")
  or vim.fn and vim.fn.getcwd()
  or "."

package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path

if not rawget(_G, "vim") then
  _G.vim = require("spec.support.vim_stub")
end
