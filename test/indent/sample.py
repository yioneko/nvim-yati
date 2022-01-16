a = [
    1,
    [
        MARKER
        2,
        [
            3
        ]
    ]
]

b = [
    1, [[
            3
            MARKER
        ],
    ]
]

c = [[[
    3
]]]

d = {
    'a': [
        2, 3
    ],
    'c': (
        [1, 2, 3],
        [
            2,
            4
        ], {
            6,
            MARKER
            8
        }
    )
}

e = (1, 2,
    3, 4,
    MARKER
    5, 6
)

a = [
    x + 1 for x in range(3)
]

b = {
    x: x + 1 for x in range(3)
}

c = (
    x * x for x in range(3)
)

d = {
    x + x for x in range(3)
}

e = [
    x + 1 for x
    in range(3)
]

def foo(a,
        b,
        c):

    if a and b and c:
        MARKER
        pass
    elif a
        or b:
        MARKER
        also_works = True
    else:
        more()
        MARKER

    baz = 'aaa' + \
        'fffff' + \
        'faaf'

    c = lambda x: \
        x + 3

    return (
        a,
        b
    )

while something():
    x = 1
    g = 2
    MARKER

while 0:
    x = 1
    g = 2
else:
    x = 2
    MARKER
    g = 4

# Comments
# Comment

try:
    # Comment
    1/0
    MARKER
except ZeroDivisionError:
    MARKER
    pass
else:
    pass
    MARKER
finally:
    pass
    MARKER

def foo():
    MARKER
    while True:
        if test:
            more()
            more()
        elif test2:
            more2()
        else:
            bar()

a = """
    String A
"""

b = """
String B
"""

c = """
    String C
    """

d = """
    String D
String D
        String D
    """

from os import (
    path,
    MARKER
    name as OsName
)

def foo(x):
    pass

class Foo:
    MARKER
    def __init__(self):
        pass

    def foo(self):
        pass
