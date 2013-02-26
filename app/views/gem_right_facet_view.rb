class GemRightFacetView < FUI::GemFacetView

  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    CGContextBeginPath(context)
    CGContextMoveToPoint(context, 56, 84)
    CGContextAddLineToPoint(context, 103, 29)
    CGContextAddLineToPoint(context, 87, 6)
    CGContextAddLineToPoint(context, 74, 29)
    CGContextAddLineToPoint(context, 56, 84)
    CGContextClosePath(context)
    color = '#FF7900'.to_color
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillPath(context)
  end

end