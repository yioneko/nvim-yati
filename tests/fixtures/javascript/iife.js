function foo() {
  return (function(
    a,
    b
  ) {
    MARKER
    ff
  })(
    c
    MARKER
  )(
    d
    MARKER
  )(123, function () {
    dosome()
  }, {
    a: 456
  });
}

