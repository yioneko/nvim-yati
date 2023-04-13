if foo then
  bar
end

if foo
  bar
else
  baz
end

bar if foo
something_else

for a in 1..5 do
  puts i
end

until other
  MARKER
end

def one
  two = <<-THREE
  four
  THREE
end

def one
  two = << THREE
  four
  THREE
end

def one
  two = <<~THREE
  four
  THREE
  # Some comments
end

def foo
  <<-EOS
  one
  \#{two} three
    four
  EOS
end

def one
  example do |something|
    MARKER
    =begin
    something that is ignored
    =end
  end
end

class OuterClass
  private :method
  def method; end
  protected
  def method; end
  private
  def method; end
  public
  def method; end
  class InnerClass
    MARKER
    def method; end
    protected
  end
end


case {a: a}
in {a:}
  MARKER
  p a
end

some_object
  .method_one
  .method_two
  .method_three

some_object
  &.method_one
  &.method_two
  MARKER
  .method_three(
    a,
    b,
    MARKER
  )

while true
  begin
    puts %{\#{x}}
    MARKER
    rescue ArgumentError
  end
end

variable =
  if condition?
    MARKER
    1
  else
    2
  end

variable = # evil comment
  case something
  when 'something'
    MARKER
    something_else
  else
    other
  end

array = [
  MARKER
  :one,
].each do |x|
  MARKER
  puts x.to_s
end

bla = {
  :one => [
    MARKER
    {:bla => :blub}
  ],
  :two => (
    {:blub => :abc}
  ),
  :three => {
    :blub => :abc
  },
  :four => 'five'
}

foo,
bar = { # TODO: whether to indent here ?
        :bar => {
          :foo => { 'bar' => 'baz' },
          MARKER
          :one => 'two',
          :three => 'four'
        }
        }
