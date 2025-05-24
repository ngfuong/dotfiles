return {
  { "hrsh7th/nvim-cmp", enabled = false },
  {
    "ms-jpq/coq_nvim",
    branch = "coq",
    dependencies = {
      { "ms-jpq/coq.artifacts", branch = "artifacts" },
      { "ms-jpq/coq.thirdparty", branch = "3p" },
    },
    config = function()
      -- Enable coq on startup
      vim.g.coq_settings = {
        auto_start = "shut-up",
      }
    end,
  },
}
