local M = {}

local term_buf = nil
local term_win = nil

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
        local width = vim.o.columns
        local height = vim.o.lines
        -- Calculate floating window size
        local win_height = math.ceil(height * 0.4 - 4)
        local win_width = math.ceil(width * 0.8)
        -- Calculate starting position
        local col = math.ceil((width - win_width) / 2)
        -- Set some options
        local opts = {
            style = "minimal",
            relative = "editor",
            width = win_width,
            height = win_height,
            row = height,
            col = col,
            border = "rounded",
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
                local new_width = vim.api.nvim_win_get_width(term_win)
                vim.api.nvim_chan_send(
                    vim.b[term_buf].terminal_job_id,
                    string.format("\027[8;%d;%dt", new_height, new_width)
                )
            end,
        })
    end
end

function M.setup()
    -- Create a user command to call this function
    vim.api.nvim_create_user_command(
        "TermFloat",
        M.toggle_floating_terminal,
        {}
    )

    -- Set up keymaps
    vim.keymap.set(
        "n",
        "<C-'>",
        ":TermFloat<CR>",
        { noremap = true, silent = true }
    )
    vim.keymap.set(
        "t",
        "<C-'>",
        "<C-\\><C-n>:TermFloat<CR>",
        { noremap = true, silent = true }
    )
    vim.keymap.set(
        "t",
        "<C-w>",
        "<C-\\><C-n><C-w>",
        { noremap = true, silent = true }
    )
end

return M
