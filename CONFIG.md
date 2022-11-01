# Config

**NOTE**: All contents here are highly unstable.

## Node Attributes

### scope

Types of nodes considered as an indent scope. Direct children of them should be indented one more level than the parent, except the first and last child, usually open and close delimiters.

```lua
function fn(fd)
  -- I'm indented
end -- Don't indent the last 'end' delimiter
```

### scope_open

Almost the same as `scope` except the last child should also be indented. This usually applies to nodes with only open delimiter.

```c
if (1)
  some_call() // should be indented
```

### scope_open_extended

Same as `scope_open` but the range of the node should be considered 'extended' to cover following empty lines.

```python
if True:

  # extended and should be indented
```

### dedent_child

List of type of nodes denote the direct children which should not be indented of the indent nodes in `scope` and `scope_open`.

```lua
if
  true
then -- 'then' should be added to 'skip_child' of 'if_statement'
  -- I'm indented
end
```

### indent_zero

The node should be zero indented. Used especially to dedent macros in C to 0.

```c
{
  {
#if 1
    // normal indent
#endif 1
  }
}
```

### indent_align

Used especially to align node to open delimiter in Python.

```python
def fun(a,
        b): # aligned indent to open delimiter of arguments
  pass
```

### indent_fallback

Compute indent by fallback method for this type of node. By default, 'ERROR' node is always denoted as `indent_fallback` because it cannot be handled by tree-sitter.

### indent_list

EXPERIMENTAL. I cannot figure out an accurate description for this so just ignore this section.

```javascript
someCall({
  a,
}, [
  b
], () => {
  foo();
});
```

### ignore

Nodes considered not exist but their children should be remained. This is similar to an unwrap operation on the node to release its children directly to its parent. Some tree-sitter syntax wraps nodes extra levels and we might want to unwrap them to make the indent calculated correctly.

```javascript
const jsx = (
  <div>
    <div>
      'jsx_text' should be unwraped to 'jsx_element'
    </div>
  </div>
);
```

## Handlers

The function signature is `fun(ctx: YatiContext): boolean|nil`.

For the return value,

- `true`: **Handled**, but continue traversing up
- `false`: **Handled**, and stop traversing
- `nil`: Not handled, try other handlers

For the two types of handlers,

- `on_initial`: On the very beginning when the base indent node is not decided yet.
- `on_traverse`: On the traversal process from bottom to up.

For the type of context and available field, refer to [context.lua](./lua/nvim-yati/context.lua).

Example handler:

```lua
function break_on_error_node(ctx)
  if ctx.node:type() == "ERROR" then
    ctx:set(-1)
    -- or return ctx:fallback() to use fallback method
    return
  end
end
```

## Fallback Method

The function signature is `fun(lnum: integer, computed: integer, bufnr: integer): integer`.

**NOTE**: Value of `computed` should be added to indent of `lnum` calculated by fallback method (unless you deliberately return -1 to use auto indent of vim).
