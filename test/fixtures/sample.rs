const X: [i32; 2] = [
    1,
    MARKER
    2,
];

fn foo(
    x: i32,
    MARKER
    y: i32,
) {
    if x > 10 {
        return 10;
        MARKER
    } else if x == 10 {
        MARKER
        return 9;
    } else {
        MARKER
        x += 10;
    }

    if let Some(x) = Some(10) {
        if x == -1 {
            MARKER
            return 0;
        }
    } else {
        MARKER
        return 1;
    }

    0
}

enum Foo {
    X,
    Y(
        MARKER
        char,
        char,
    ),
    Z {
        x: u32,
        y: u32,
        MARKER
    },
}

struct Foo {
    x: i32,
    y: i32,
    MARKER
}

impl Foo {
    fn foo() -> i32 {
        while x > 0 {
            x -= 1;
            for i in 0..3 {
                MARKER
                x += 1;
                loop {
                    x += 1;
                    if x < 100 {
                        MARKER
                        continue;
                    }
                    break;
                }
            }
        }
        let mut trie = vec![TrieNode {
            is_end: false,
            MARKER
            next: [None; 26],
        }];

    }
    MARKER
}

trait Bar {
    fn bar();
    MARKER
}

macro_rules! foo {
    ($a:ident, $b:ident, $c:ident) => {
        struct $a;
        struct $b;
    },
    ($a:ident) => {
        struct $a;
    },
}

foo! {
    (bar) => {
        MARKER
    }
}

fn foo(x: i32) -> i32 {
    match x {
        0 => 1,
        1 => {
            MARKER
            2
        },
        2 | 3 => {
            4
        }
    }
}

mod foo {
    const X: i32 = 1;
    mod bar {
        MARKER
        const Y: i32 = 1;
    }
}

fn foo() {
    let a = "hello
world";

    let b = "hello\
        world";

    let c = r#"
        hello
        world
    "#;
}

fn foo<T>(t: T) -> i32
where
    T: Debug,
    MARKER
    U: Integer,
{
    1
}

fn foo<T>(t: T) -> i32 where
    T: Debug,
{
    let paths: Vec<_> = ({
        fs::read_dir("test_data")
            .unwrap()
            MARKER
            .cloned()
    })
    .collect();

    statement();
}

// Comment
/*
 * comment
 * comment
 */
impl<T> Write for Foo<T>
where
    T: Debug,
{
    // Comment
}

fn foo() {
    {{{
        let explicit_arg_decls =
            explicit_arguments.into_iter()
                .enumerate()
                .map(|(index, (ty, pattern))| {
                    let lvalue = Lvalue::Arg(index as u32);
                    block = this.pattern(block,
                        argument_extent,
                        MARKER
                        hair::PatternRef::Hair(pattern),
                        &lvalue);
                    ArgDecl { ty: ty }
                });
    }}}
}

fn f<
    X,
    MARKER
    Y
>() {
    g(|_| {
        let x: HashMap<
            String,
            MARKER
            String,
        >::new();
        h();
    })
    .unwrap();
    h();
}

fn floaters() {
    let x = Foo {
        field1: val1,
        field2: val2,
    }
    .method_call().method_call();

    let y = if cond {
        val1
    } else {
        val2
    }
    .await
    .method_call([
        1,
        3,
        MARKER
        1
    ]);

    x =
        456
            + 789
            + 111
            - 222;

    // NOTE: rustfmt do not expand binary expression
    if aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
        && bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
        || ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
            && ecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
    {
    }

    {
        match x {
            PushParam => {
                // comment
                stack.push(mparams[match cur.to_digit(10) {
                    Some(d) => d as usize - 1,
                    None => return Err("bad param number".to_owned()),
                }]
                .clone()
                MARKER
                .await
                MARKER
                .unwrap()
                );
            }
        }

        if let Some(frame) = match connection.read_frame().await {
            Ok(it) => it,
            Err(err) => return Err(err),
            MARKER
        } {
            println!("Got {}", frame);
        }
    }
}
