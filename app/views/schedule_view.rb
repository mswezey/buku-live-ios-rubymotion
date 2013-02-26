class ScheduleView < UIWebView
  attr_accessor :activities

  def initWithFrame(frame)
    if super
      self.backgroundColor = '#006670'.to_color.colorWithAlphaComponent(0.42)
      self.setOpaque false

      fullURL = "#{App.delegate.frequency_app_uri}/api/mobile/events"
      url = NSURL.URLWithString(fullURL)
      requestObj = NSURLRequest.requestWithURL(url)
      self.loadRequest(requestObj)
      self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite
      self.scrollView.scrollEnabled = false
      self.scrollView.bounces = false
    end
    self
  end

end