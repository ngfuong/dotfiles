return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local function input_lang()
      local handle = io.popen(
        "defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep 'KeyboardLayout Name' | awk -F ' = ' '{print $2}' | tr -d '\";'"
      )
      local result = handle:read("*a")
      handle:close()
      return result:gsub("\n", "") or "Lang?"
    end

    table.insert(opts.sections.lualine_x, input_lang)
  end,
}
