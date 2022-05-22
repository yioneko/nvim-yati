func s:func()
  "{{{
  let l = [1,
    \2,
    \3
  \]

  let d = {
    \1: 1,
    \2: 2,
    \3: 3,
  \}
  while a && b
    " Comment
    let lnum = prevnonblank(lnum - 1)
  endwhile
  if aaa
    if aaa
      return b:bbb
    endif
  endif
  if b:bbb
    return b:bbb
  else
    MARKER
    return -1
  endif

  try
    MARKER
    normal! %
  catch
    MARKER
    let sss = 0
  endtry

endfunc "}}}

augroup Group
  autocmd!
  MARKER
  autocmd BufEnter * call s:func()
augroup END

func s:func2(
  \a,
  \b,
  \c
\)
  if ttt =~ '456'
    \ && s:bool(123)
    \ && s:bool(456)
    return
  endif

  lua << EOF
  function fun()
    if a == b then
      MARKER
    end
  end
  EOF
endfunc
