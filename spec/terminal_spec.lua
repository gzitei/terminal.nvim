-- spec/terminal_spec.lua
-- Tests for lua/terminal/init.lua
-- Run with: make test   or   busted spec/terminal_spec.lua

require("spec.support.init")

-- ── helpers ──────────────────────────────────────────────────────────────────

local function fresh()
    package.loaded["terminal"] = nil
    -- Clear command/keymap tracking
    vim._commands = {}
    vim._keymaps = {}
    return require("terminal")
end

-- ─────────────────────────────────────────────────────────────────────────────
describe("terminal module", function()
    it("loads without error", function()
        assert.has_no.errors(function() fresh() end)
    end)

    it("returns a table with setup function", function()
        local term = fresh()
        assert.is_table(term)
        assert.is_function(term.setup)
    end)

    it("has toggle_floating_terminal function", function()
        local term = fresh()
        assert.is_function(term.toggle_floating_terminal)
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────
describe("setup", function()
    it("registers TermFloat user command", function()
        local term = fresh()
        term.setup()
        assert.is_table(vim._commands["TermFloat"])
    end)

    it("registers keymaps", function()
        local term = fresh()
        term.setup()
        assert.is_true(#vim._keymaps > 0)
    end)

    it("registers both normal and terminal mode keymaps", function()
        local term = fresh()
        term.setup()
        local modes = {}
        for _, km in ipairs(vim._keymaps) do
            modes[km.mode] = true
        end
        assert.is_true(modes["n"])
        assert.is_true(modes["t"])
    end)
end)
