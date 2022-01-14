local tab = {
  as = { ff = "" },
  ad = {
    a = "",
    b = {
      f = function()
        MARKER
      end,
    },
    MARKER
    x = ({
      f = (function()
        MARKER
      end),
    })
  }
}

function foo(x)
  local bar = function(a, b, c)
    return (a
      + b
      + c
    )
  end
  return bar(
    x,
    MARKER
    1,
    2)
  MARKER
end

local x =
  10
if x > 3 then
  MARKER
  x = 3
elseif x < 3 then
  x = -3
  MARKER
  if
    x
    MARKER
  then
    if
      x
      and x * 5
      or x - 6
      MARKER
    then
      while df do
        for x, x in ipairs(aa) do
          cx
          MARKER
          repeat
            x = x + 1
          until x > 100
        end
        MARKER
      end
      while
        aaa
        MARKER
      do
        fdsf
      end
    end
  end
else
  MARKER
  if x > 0 then
    local dd =
      45
  end
  x = 0
end

-- comment line
local function ffa(
  a,
  MARKER
  b
)
  function fff(
    a,
    b
    -- [[
    -- block comment
    -- block comment
    -- ]]
    MARKER
  )
    -- comment
    -- comment
    MARKER
    fdsf
  end

  vim.cmd([[
    augroup G
      MARKER
      au!
      au BufEnter,BufWinEnter * lua require'mod'.func()
    augroup END
    MARKER
    ]]) -- TODO: Fix this (modification of core algorithm is needed)

  local ss = [[
  fdsafasf
fdsagdgds
  ]]
end

