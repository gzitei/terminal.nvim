local M = {}

---@class TerminalOpts
---@field keymap? string  Key to toggle the terminal (default: "<C-t>")
---@field width?  number  Window width as a fraction of the editor 0–1 (default: 0.8)
---@field height? number  Window height as a fraction of the editor 0–1 (default: 0.4)
---@field row?    number  Vertical anchor: 0 = top, 1 = bottom (default: 1.0)
---@field col?    number  Horizontal anchor: 0 = left, 0.5 = center, 1 = right (default: 0.5)

local term_buf = nil
local term_win = nil

local default_opts = {
    keymap = "<C-t>",
    width = 0.8,   -- fraction of editor width
    height = 0.4,  -- fraction of editor height
    row = 1.0,     -- fraction of editor height (1.0 = bottom edge)
    col = 0.5,     -- fraction of editor width  (0.5 = centered)
}

local config = {}

function M.toggle_floating_terminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        if vim.fn.win_getid() ~= term_win then
            -- Terminal window exists and is not focused, so focus it
            vim.api.nvim_set_current_win(term_win)
            vim.cmd("startinsert")
        else
            -- Terminal window is focused, so hide it
            vim.api.nvim_win_hide(term_win)
            term_win = nil
        end
    else
        -- Create or show terminal window
        local total_w = vim.o.columns
        local total_h = vim.o.lines
        -- Calculate floating window size
        local win_width  = math.ceil(total_w * config.width)
        local win_height = math.ceil(total_h * config.height - 4)
        -- Calculate starting position
        local col = math.ceil((total_w * config.col) - win_width / 2)
        local row = math.ceil(total_h * config.row)
        -- Set some options
        local opts = {
            style    = "minimal",
            relative = "editor",
            width    = win_width,
            height   = win_height,
            row      = row,
            col      = col,
            border   = "rounded",
        }
        if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            -- Reuse existing buffer
            term_win = vim.api.nvim_open_win(term_buf, true, opts)
        else
            -- Create a new buffer for the terminal
            term_buf = vim.api.nvim_create_buf(false, true)
            term_win = vim.api.nvim_open_win(term_buf, true, opts)
            -- Change to the directory of the current buffer
            vim.api.nvim_command("lcd %:p:h")
            -- Open a terminal in the new buffer
            vim.fn.termopen(vim.o.shell, {
                cwd = vim.fn.getcwd(),
            })
        end
        -- Enter insert mode
        vim.api.nvim_command("startinsert")
        -- Resize terminal on nvim resize
        vim.api.nvim_create_autocmd("VimResized", {
            buffer = term_buf,
            callback = function()
                local new_height = vim.api.nvim_win_get_height(term_win)
                local new_width  = vim.api.nvim_win_get_width(term_win)
                vim.api.nvim_chan_send(
                    vim.b[term_buf].terminal_job_id,
                    string.format("\027[8;%d;%dt", new_height, new_width)
                )
            end,
        })
    end
end

---@param opts? TerminalOpts
function M.setup(opts)
    config = vim.tbl_deep_extend("force", default_opts, opts or {})

    -- Create a user command to call this function
    vim.api.nvim_create_user_command(
        "TermFloat",
        M.toggle_floating_terminal,
        {}
    )

    vim.keymap.set(
        "n",
        config.keymap,
        M.toggle_floating_terminal,
        { noremap = true, silent = true, desc = "Toggle floating terminal" }
    )
    vim.keymap.set(
        "t",
        config.keymap,
        function()
            vim.cmd("stopinsert")
            M.toggle_floating_terminal()
        end,
        { noremap = true, silent = true, desc = "Toggle floating terminal" }
    )
    vim.keymap.set(
        "t",
        "<C-w>",
        "<C-\\><C-n><C-w>",
        { noremap = true, silent = true }
    )
end

return M
