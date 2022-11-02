local o = require("nvim-yati.config")
local is_mod_enabled = require("nvim-treesitter.configs").is_enabled

local M = {}
local stored_expr = {}

function M.attach(bufnr, lang)
  if is_mod_enabled("indent", lang, bufnr) then
    if not o.get_user_config().suppress_conflict_warning then
      vim.notify_once(
        string.format(
          '[nvim-yati] is disabled. The builtin indent module has been enabled, add "%s" to the disabled language of indent module if you want to use nvim-yati instead. Otherwise, disable "%s" for nvim-yati to suppress the message.',
          lang,
          lang
        ),
        vim.log.levels.INFO,
        { title = "[nvim-yati]: Disabled" }
      )
    end
    return
  end
  stored_expr[bufnr] = vim.bo[bufnr].indentexpr
  vim.bo[bufnr].indentexpr = 'v:lua.require("nvim-yati.indent").indentexpr()'
end

function M.detach(bufnr)
  vim.bo[bufnr].indentexpr = stored_expr[bufnr]
  stored_expr[bufnr] = nil
end

return M
