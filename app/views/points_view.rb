class PointsView < UIView
  attr_accessor :left_points, :middle_points, :right_points, :total_points_formatted

  def initWithFrame(frame)
    if super

      @points_value_label = UILabel.alloc.initWithFrame([[0,0],[160,50]])
      @points_value_label.text = "loading"
      @points_value_label.textColor = UIColor.whiteColor
      @points_value_label.textAlignment = UITextAlignmentCenter
      @points_value_label.font = UIFont.fontWithName("DIN-Bold", size:24)
      @points_value_label.backgroundColor = '#133948'.to_color
      self.addSubview(@points_value_label)

      @gem_view = GemView.alloc.initWithFrame([[28,59],[105, 92]])
      self.addSubview(@gem_view)
      self.backgroundColor = '#39a7d2'.to_color

      # setPoints(rand(5000),rand(5000),rand(5000))

      # self.when_tapped do
      #   setPoints(rand(5000),rand(5000),rand(5000))
      # end

    end
    self
  end

  def setPoints(left_points, middle_points, right_points)
    @gem_view.left_points = left_points
    @gem_view.middle_points = middle_points
    @gem_view.right_points = right_points
    total_points = left_points + middle_points + right_points
    @total_points_formatted = total_points.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
    @points_value_label.text = @total_points_formatted
  end

  def resetPoints
    @gem_view.left_points = 0
    @gem_view.middle_points = 0
    @gem_view.right_points = 0
    @points_value_label.text = "0"
  end

  def total_points_formatted
    @total_points_formatted ? @total_points_formatted : "0"
  end

  def left_points
    @gem_view.left_points
  end

  def middle_points
    @gem_view.middle_points
  end

  def right_points
    @gem_view.right_points
  end

end