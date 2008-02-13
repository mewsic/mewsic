def shuffle(array)
  size = array.size
  r = [rand(size),rand(size)]
  array[ r.min, (r.max + 1) ].join(" ")
end