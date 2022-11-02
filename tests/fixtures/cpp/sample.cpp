class Foo {
public:
  class Bar {
  private:
    MARKER
    int x;
    void f() {
      cout
        MARKER
        << "at 1"
        << "at 1"
        << std::end;
      cin
        >> i;
      cin >>
        j;
    }
  };
private:
  int y;
};

void foo() {
  auto f2 = [](int x, int y)
    -> int {
      return x + y;
    };
}

namespace myspace {

MARKER

size_t hash<
  CharacterSet
  MARKER
>::operator()(const CharacterSet &character_set) const {
  size_t result = 0;
  for (uint32_t c :
    MARKER
    character_set.included_chars) {
    hash_combine(&result, c);
  }
}

}

extern "C" {

MARKER
void foo() {
  if (4
    + 5 < 10) {
    pass;
  }

  if (4 + 5
    < 10) {
    MARKER
    pass;
  } else {
    MARKER
  }

  for (
    int i = 0;
    MARKER
    i < 10;
    i++)
    cout << i;

  doit
    MARKER
    .right
    .now();

  try {
    dosome();
    MARKRE
  } catch (
    MARKER
    e
  ) {
    MARKER
    pass;
  }

}
}

struct AltStruct
{
  AltStruct(int x, double y):
    x_{x}
    , y_{y}
  {}
};

template <
  MARKER
  typename Second
>
typedef SomeType<OtherType,
  Second,
  5> TypedefName;

typedef std::tuple <int,
  double, long &, const char *> test_tuple;

