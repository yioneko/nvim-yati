a
  .b
  .c do |x|
    something
  end

a.
  b.
  c { |x|
    something
  }

@foo ||=
  something do
    "other"
  end

module X
  Class.new do
    MARKER
  end
end

proc do |(a, b)|
  puts a
  MARKER
  puts b
end

proc do |a: "asdf", b:|
  proc do
    puts a, b
  end
end
