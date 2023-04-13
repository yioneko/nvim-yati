def foo
  opts.on('--coordinator host=HOST[,port=PORT]',
          'Specify the HOST and the PORT of the coordinator') do |str|
    MARKRE
    h = sub_opts_to_hash(str)
    puts h
  end
end
