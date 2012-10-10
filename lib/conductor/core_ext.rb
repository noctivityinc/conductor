Array.class_eval do
  def sum_it(attribute)
    self.map {|x| x.send(attribute) }.compact.sum
  end

  def weighted_mean_of_attribute(attribute)
    self.map {|x| x.send(attribute) }.compact.weighted_mean
  end

  def weighted_mean
    w_sum = sum(self)
    return 0.00 if w_sum == 0.00
    
    w_prod = 0
    self.each_index {|i| w_prod += (i+1) * self[i].to_f}
    w_prod.to_f / w_sum.to_f
  end
end
