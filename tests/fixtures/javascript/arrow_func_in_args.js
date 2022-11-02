someFunc((a1, a2) =>
  anotherFunc(
    a1,
    MARKER
    a2,
  ),
)

someFunc(
  1111,
  (a1, a2) =>
    anotherFunc(
      MARKER
      a1,
      a2,
    ),
)
