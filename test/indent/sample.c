int x[] = {
  1, 2, 3,
  4, 5,
  6
};

int y[][2] = {
  {0, 1},
  {1, 2},
  {
    2,
    3
    MARKER
  },
};

/**
 * Fnction foo
 * @param[out] x output
 * @param[in] x input
 */
void foo(int *x, int y) {
  *x = y;
  if (x > 10) {
    if (x < 20) {
      MARKER
    }
  } else if (x < -10) {
    MARKER
    x = -10;
  } else {
    MARKER
    x = -x;

    // TODO: Is this indent better?
    // and it's hard to implement because the binary_expression is right associative
    // if (
    //   x ||
    //   y &&
    //   z
    // ) {
    //   return;
    // }

    if ((x &&
      MARKER
      y) ||
      (z &&
        x)) {
      return;
    }

    int z = (x + y) *
      (x - y);
  }
}

struct foo {
  int x, y;
};

struct foo bar(int x,
  int y) {
  return (struct foo) {
    MARKER
    .x = x,
    .y = y
  };
}

enum foo {
  A = 1,
  B,
  C,
};

int
foo(int a, int b)
{
  goto error;
  return 0;
error:
  MARKER
  while (x > 0) {
    x--;
    MARKER
    continue;
  }

  for (
    int i = 0;
    MARKER
    i < 10;
    i++)
    cout << i;

  for (int i = 0; i < 5; ++i) {
    x++;
    MARKER
    break;
  }

  do {
    x++;
  } while (x < 0);

}

// TODO: Add empty new line cause syntax error (need insert '\' automatically)
#define FOO(x) do { \
    x = x + 1;  \
    x = x / 2;  \
  } while (x > 0);

int foo(int x) {
  if (x > 10)
    return 10;
  else
    return x;

  while (1)
    x++;

  if (x) {
    if (y) {
#if 1
      MARKER
      for (int i = 0; i < 3; ++i)
        x--;
#else
      x++;
#endif
    }
  }

  const char *a = "hello \
  world";

  const char *b = "hello "
    "world";
}

struct foo {
  int a;
  struct bar {
    MARKER
    int x;
  } b;
};

union baz {
  MARKER
  struct foo;
  int x;
};

void foo(int x) {
  switch (x) {
    MARKER
    case 1:
      x += 1;
      break;
    case 2:
      x += 2;
      break;
    case 3:
      MARKER
      x += 3;
      break;
    case 4: {
      MARKER
      x += 4;
      break;
    }
    default:
      int y = (x > 10)
        ? 10
        : (x < -10)
          ? -10
          : x;
  }
}
