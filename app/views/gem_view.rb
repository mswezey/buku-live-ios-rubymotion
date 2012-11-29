class GemView < UIView
  attr_accessor :left_points, :middle_points, :right_points

  def initWithFrame(frame)
    if super
      @image_view = UIImageView.alloc.initWithImage(UIImage.imageNamed("gem.png"))
      @left_facet = GemLeftFacetView.alloc.initWithFrame([[0,0], [self.size.width, self.size.height]])
      @middle_facet = GemMiddleFacetView.alloc.initWithFrame([[0,0], [self.size.width, self.size.height]])
      @right_facet = GemRightFacetView.alloc.initWithFrame([[0,0], [self.size.width, self.size.height]])
      self.addSubview(@left_facet)
      self.addSubview(@middle_facet)
      self.addSubview(@right_facet)
      self.addSubview(@image_view)
      self.backgroundColor = '#39a7d2'.to_color

      # svgDocument = SVGDocument.documentNamed("gem")
      # docView = SVGDocumentView.documentViewWithDocument(svgDocument)
      # @gemLayer = docView.rootLayer.sublayers.first
      # self.layer.addSublayer(@gemLayer)
    end
    self
  end

  def left_points=(left_points)
    @left_points = left_points
    @left_facet.points = left_points
  end

    def middle_points=(middle_points)
    @middle_points = middle_points
    @middle_facet.points = middle_points
  end

  def right_points=(right_points)
    @right_points = right_points
    @right_facet.points = right_points
  end

end