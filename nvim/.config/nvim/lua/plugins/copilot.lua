return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
  },

  -- Disable Tab in blink.cmp to avoid conflict
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      keymap = {
        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
      },
    },
  },
}
