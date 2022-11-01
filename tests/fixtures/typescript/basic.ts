interface Foo {
  bar: string;
  MARKER
  fun: (
    a: {
      MARKER
      b: string;
      c: number;
    },
    b: [
      number,
      MARKER
      {
        a: Array<string>;
      }
    ],
    c
  ) => {
    MARKER
    baz: string;
  };
}

interface Bar
{
  aaa: a extends object
    ? a
    : c extends AAA
    ? foo
    : bar;
}

type Foo2<A,
  B,
  MARKER
  C extends {
    a: A;
    b: B;
  }
> = {
  bar: string;
  baz: Record<
    A,
    B
  >
}

enum e {
  a,
  MARKER
  b,
}
