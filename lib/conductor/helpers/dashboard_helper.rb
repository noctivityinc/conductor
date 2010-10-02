module DashboardHelper
  def current_weights(group_name, group)
    total = group.inject(0) {|res, x| res += x.weight}
    data = []
    legend = []
    group.each do |x|
      legend << "#{x.alternative} (#{"%0.2f" % (x.weight.to_f/total.to_f*100)}%)"
      data << x.weight
    end
    return Gchart.pie(:data => data, :legend => legend, :size => '600x200')
  end
  
  def daily_stats(group_name, group)
    data = []
    legend = []
    colors = []
    group.group_by(&:alternative).map do |alternative, rows|
      legend << alternative
      data << rows.sort_by(&:activity_date).map(&:views)
      colors << random_color
    end
    
    min_value = group.min {|a,b| a.views <=> b.views }.views
    max_value = group.max {|a,b| a.views <=> b.views }.views
    dr = group.min {|a,b| a.activity_date <=> b.activity_date }.activity_date..group.max {|a,b| a.activity_date <=> b.activity_date }.activity_date
    
    return Gchart.line(:size => '600x250', 
                :legend => legend,
                :data => data,
                :axis_with_labels => ['x','y'],
                :axis_labels => [dr.step(3).map {|x| x},(min_value..max_value).step(10).map {|x| x}],
                :line_colors => colors)
  end
  
  def weight_history(group_name, group)
    data = []
    legend = []
    colors = []
    group.group_by(&:alternative).each do |alternative, rows|
      legend << alternative
      data << rows.sort_by(&:computed_at).map(&:weight)
      colors << random_color
    end
    
    min_value = group.min {|a,b| a.weight <=> b.weight }.weight
    max_value = group.max {|a,b| a.weight <=> b.weight }.weight
    dr = group.min {|a,b| a.computed_at <=> b.computed_at}.computed_at.to_date..group.max {|a,b| a.computed_at <=> b.computed_at }.computed_at.to_date
    
    return Gchart.line(:size => '700x350', 
                :legend => legend,
                :data => data,
                :axis_with_labels => ['x','y'],
                :axis_labels => [dr.step(1).map {|x| x},(min_value..max_value).step(10).map {|x| x}],
                :line_colors => colors,
                :encoding => 'extended')
  end
  
  
  # Method to select a random color from a list of hex codes
  #
  # Example: random_color()
  # => "ff0000"
  def random_color()
    color_list = %w{000000 0000ff ff0000 ffff00 00ffff ff00ff 00ff00}
    return color_list[rand(color_list.size)]
  end
end
