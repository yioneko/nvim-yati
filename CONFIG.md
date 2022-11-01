# Config

The following sections documents fields of indent configuration.

### scope

Types of nodes considered as an indent scope. Direct children of them should be indented one more level than the parent, except the first and last child, usually open and close delimiters.

**Example**:

```lua
function fn(fd)
  -- I'm indented
end -- Don't indent the last 'end' delimiter
```

### scope_open

Almost the same as `scope` except the last child should also be indented. This usually applies to nodes with only open delimiter.

**Example**:

```c
if (1)
  some_call() // should be indented
```

### scope_open_extended

Same as `scope_open` but used to relocate 

**Example**:

``` c
if (1)
  // should be indented
```

### skip_child

List of `(indent_node_type, { literal = literal_types, named = named_types })` key-value pairs to denote the direct children which should not be indented of the indent nodes in `indent` and `indent_last`.

**Example**:

```lua
if
  true
then -- 'then' should be added to 'skip_child' of 'if_statement'
  -- I'm indented
end
```

### ignore_within

Indent of contents within these nodes should be kept as is. Usually multi-line comments and strings.

**Example**:

```javascript
const str = `
one
       two
  three
`;
```

### ignore_outer

Ignore indent calculated from parents of the node. Used especially to dedent macros in c to 0.

**Example**:

```c
{
  {
#if 1
    // normal indent
#endif 1
  }
}
```

### ignore_self

Nodes considered not exist but their children should be remained. This is similar to an unwrap operation on the node to release its children directly to its parent. Some tree-sitter syntax wraps nodes extra levels and we might want to unwrap them to make the indent calculated correctly.

**Example**:

```javascript
const jsx = (
  <div>
    <div>
      'jsx_text' should be unwraped to 'jsx_element'
    </div>
  </div>
);
```

### hooks

This formally refers to two fields `hook_node` and `hook_new_line`, used to hook different situations. The hook takes a context argument, and returns new indentation value, next node to traverse from, and whether to continue the current iteration or default processing.

The fields of context:

| name       | type                            | description                                       |
| ---------- | ------------------------------- | ------------------------------------------------- |
| bufnr      | number                          | buffer handle                                     |
| lnum       | number                          | number of line to calculate indentation for       |
| node       | tsnode `:h lua-treesitter-node` | current in-progress node                          |
| tree       | tstree `:h lua-treesitter-tree` | the tree which the node resides within            |
| upper_line | number                          | the start line number of the tree after shrinking |
| shift      | number                          | value of one shift, `:h shiftwidth`               |
| indent     | number                          | calculated indentation value                      |
