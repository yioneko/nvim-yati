const af3 = (c) =>
  ((d) =>
    123
  )(
    somebool
      ? foo(
          a,
          MARKER
          b
        )
      : bar(
          c,
          d
        )
      ? dd
      : baz(
          MARKER
          c
        ),
    anotherbool ?
      foo(
        a,
        MARKER
        b
      ) : bar(
        c,
        d
      ),
    MARKER
    b
  )

const conf = merge(base, {
  caaa: {
    aaaa: bbbb
  },
  aaacccc: foo
}, someCond() ? abc: {
  fooo,
  MARKER
})
