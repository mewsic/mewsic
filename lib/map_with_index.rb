# http://snippets.dzone.com/posts/show/5119
class Array
  def map_with_index!
    each_with_index { |e, i| self[i] = yield(e, i) }
  end

  def map_with_index(&block)
    dup.map_with_index!(&block)
  end
end
