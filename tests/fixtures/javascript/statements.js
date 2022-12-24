if (true)
  foo();
else
  bar();

if (true) {
  foo();
  bar();
} else if (
  false
) {
  (1 + 2)
  MARKER
} else {
  MARKER
  foo();
}

while (a === 1
  || b === 1)
  inLoop();

while (condition)
  inLoop();
after(
  aaaaaaaa
)
  .fooo // NOTE: this conforms to prettier behavior
  .bar(fffff);

while (mycondition) {
  MARKER
  sdfsdfg();
}

while (mycondition) {
  sdfsdfg();
  if (test) {
    more()
  }}

while (mycondition)
  if (test) {
    more()
  }

switch (e) {
  case 4:
    MARKER
  case 5:
    something();
    more();
  case 6:
    somethingElse();
  case 7:
  default:
    MARKER
}

for (
  let i = 0;
  i < 10;
  i++
) {
  for (
    const { a,
      b,
      c,
      MARKER
    } of foo
  ) {
    MARKER
  }
}
