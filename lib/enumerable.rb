module Enumerable
  def sum
    inject { |a,b| a + b }
  end

  def magnitude
    Math.sqrt(map { |x| x*x }.sum)
  end
end
