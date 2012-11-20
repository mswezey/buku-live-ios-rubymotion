class GemMiddleFacetView < FUI::GemFacetView

  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    CGContextBeginPath(context)
    CGContextMoveToPoint(context, 53, 84)
    CGContextAddLineToPoint(context, 73, 29)
    CGContextAddLineToPoint(context, 52, 4)
    CGContextAddLineToPoint(context, 32, 29)
    CGContextAddLineToPoint(context, 53, 84)
    CGContextClosePath(context)
    color = '#ffae22'.to_color
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillPath(context)
  end

end