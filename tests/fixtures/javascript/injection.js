function inject() {
  const style = css`
    .foo {
      MARKER
      color: red;
    }
  `
  const query = gql`
    {
      args(
        var: $var
        MARKER
      )
      fds(
        obj: {
          str: "hello"
          list: [
            "hello"
            MARKER
          ]
        }
      )
    }
  `
  const interpolated = `
    fdsfsaf
    ${
      (function(
        a,
        b) {
      })(
        () => {
          MARKER
          return a + b
        }
        2,
      )
    }
  `
}
