local helper = require("tests.helper")

helper.setup()

require("nvim-treesitter.configs").setup({
  yati = {
    default_lazy = true,
  },
})

local test_langs = {
  { "c", "c" },
  { "cpp", "cpp" },
  { "graphql", "graphql" },
  { "html", "html" },
  { "javascript", "js" },
  { "json", "json" },
  { "lua", "lua" },
  { "python", "py" },
  { "rust", "rs" },
  { "toml", "toml" },
  { "tsx", "tsx" },
  { "typescript", "ts" },
  { "vue", "vue" },
}

for _, l in ipairs(test_langs) do
  local lang = l[1]
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
