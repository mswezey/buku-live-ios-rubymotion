class GemLeftFacetView < FUI::GemFacetView

  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    CGContextBeginPath(context)
    CGContextMoveToPoint(context, 49, 84)
    CGContextAddLineToPoint(context, 30, 32)
    CGContextAddLineToPoint(context, 18, 8)
    CGContextAddLineToPoint(context, 5, 25)
    CGContextAddLineToPoint(context, 5, 32)
    CGContextAddLineToPoint(context, 49, 84)
    CGContextClosePath(context)
    color = '#ff02f6'.to_color
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillPath(context)
  end

end