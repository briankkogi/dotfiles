-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
  end,
})

local autoreload_timer = vim.uv.new_timer()

-- Check if the timer was created successfully before using it
if autoreload_timer then
  autoreload_timer:start(
    0,
    1000,
    vim.schedule_wrap(function()
      local bufnr = vim.api.nvim_get_current_buf()
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })

      if vim.api.nvim_get_mode().mode == "n" and buftype == "" and not vim.bo.modified then
        vim.cmd("checktime")
      end
    end)
  )
end
