def shuffle(array)
  array.sort_by{rand}.join(' ')[0..rand(array.size)]
end
