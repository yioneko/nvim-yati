<div>
  MARKER
  <img
    src="https://www"
  />
  <p
    class="foo"
    MARKER
    id="bar"
  >
    MARKER
  </p>
</div>


<?php
$array = array(
  "foo" => "bar",
  42    => 24,
  "multi" => array(
    "dimensional" => array(
      MARKER
      "array" => "foo"
    )
  )
);

$arr = [
  'f' =>
    fd()
      ->f1($a)
      ->f2(
        $a,
        $b,
        MARKER
      ),
];

$fn1 = static fn($a,
  $b,
  $c
) => "something";

$var =
  $a ??
    ($b ??
      $e) ?:
    $a;

$callback =
  $var ??
    (function() use (
      $a,
      $b,
      MARKER
      $c
    ) {
      return true;
    } ??
      function() {
        return true;
      });

if (true) {
  MARKER
  return 1;
} elseif (false) {
  MARKER
  return 2;
} else if (null) {
  MARKER
  return 3;
} else {
  MARKER
  return;
}

if (true):
  MARKER
  return 1;
elseif (false):
  MARKER
  if (
    $a === "1" &&
      !is_null($c) &&
      $b->mem() ===
        "fds"
  ) {
    while (list(
      0 => $a,
      1 => $b,
      2 => $c,
      3 => $d,
    ) = $arr) {
      echo " <tr>\\n" .
        "  <td><a href=\\"info.php?id=$id\\">$name</a></td>\\n" .
          "  <td>$salary</td>\\n" .
          " </tr>\\n";
      while ($i <= 5):
        foreach (
          [
            'one' => [
              'string',
              'other-string'
              MARKER
            ],
            'two' => [
              'string',
              'other-string'
            ],
          ]
          as $key => $value
        )
          MARKER

        for ($i = 0; $i <= 5; $i++) {
          MARKER
          for (;;):
            $test = $i;
          endfor;
        }
      endwhile;
      do {
        MARKER
      } while (
        $i <= 5 &&
          $i >= 0
      );
    }
  }
else:
  MARKER
  return;
endif;

function fun2(&$a, &$b): void
{
  switch (2) {
    case 1:
      MARKER
      $a = "first";
      break;
    case 10:
    case 20:
      $test = "big";
      break;
    case 100:
    default:
      $test = 1;
  }
  switch ($var):
    case 1:
    case 2:
      echo "Goodbye!";
      break;
    default:
      MARKER
      echo "I only understand 1 and 2.";
  endswitch;
}

try {
  MARKER
  throw new OtherException();
} catch (
  Exception | TestException $e
) {
  MARKER
  echo "Caught exception: ", $e->getMessage();
} catch (OtherException $i) {
  echo "Caugh other";
} finally {
  MARKER
  echo "First finally";
}

trait A {
  function f1() {}
  function f2() {}
}
class Foo extends Base
{
  use testTrait, implementingTrait {
    A::testFunction insteadof C;
    MARKER
  }

  public static function f1()
  {
    MARKER
  }
  public static function oLabel()
  {
    return __(parent::__FUNCTION__());
  }
}
interface Foo extends
  MyClass,
  MyOtherClass,
  MyOtherOtherOtherClass,
  MyVeryVeryVeryLongClassName
{
}

use Vendor\\Package\\SomeNamespace\\{
  MARKER
  ClassZ
};

// Comment
namespace foo {
  global $aaa,
    $bbb,
    MARKER
    $ccc;

  function bar($a, $b) {
    MARKER
    // Comment
    /**
     * Comment
     * Comment
     */
    $nest = match(match($a) {true => 1, false => 2}) {
      1 => match($b) {
        'ok' => true,
        'fail' => false,
        default => false
        MARKER
      },
      2 => 'null'
    };
  }
  echo bar(2, 3);
}
?>
