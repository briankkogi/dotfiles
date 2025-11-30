return {
  "okuuva/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    enabled = true,
    trigger_events = {
      immediate_save = { "BufLeave", "FocusLost" },
      defer_save = { "InsertLeave", "TextChanged" },
    },
    debounce_delay = 1000,
    condition = function(buf)
      local fn = vim.fn
      if fn.getbufvar(buf, "&modifiable") == 1 and fn.getbufvar(buf, "&filetype") ~= "" then
        return true
      end
      return false
    end,
  },
}

