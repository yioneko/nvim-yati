local helper = require("tests.helper")

helper.setup()

require("nvim-treesitter.configs").setup({
  yati = {
    default_lazy = true,
  },
})

local test_langs = {
  "c",
  "cpp",
  "graphql",
  "html",
  "javascript",
  "json",
  "lua",
  "python",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vue",
}

for _, lang in ipairs(helper.get_test_langs()) do
  describe(lang, function()
    after_each(function()
      vim.cmd("bdelete!")
    end)

    for _, file in ipairs(helper.get_test_files(lang)) do
      it(string.format("indent should be correct [%s]", helper.basename(file)), function()
        vim.cmd("edit! " .. file)
        for lnum, indent in helper.expected_indents_iter("MARKER", 0) do
          assert.same_indent(lnum, indent)
        end
      end)
    end
  end)
end
