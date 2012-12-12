class ActivityView < UIWebView
  attr_accessor :activities, :activities_with_profile

  def initWithFrame(frame)
    if super
      path = NSBundle.mainBundle.bundlePath
      @baseURL = NSURL.fileURLWithPath(path)

      self.backgroundColor = UIColor.clearColor
      self.setOpaque false
      self.loadHTMLString("<html>#{html_head}<body><div class='activity din-medium'>Loading activity...</div></body></html>", baseURL:@baseURL)
      self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite
    end
    self
  end

  def activities=(activities)
    if activities.size > 0
      list = []
      activities.each do |activity|
        a = Frequency::Activity.new(activity)
        list << a.html_string
      end
      load_html list.join('')
    else
      load_html 'No activity yet'

    end
  end

  def activities_with_profile=(activities_with_profile)
    if activities_with_profile.size > 0
      list = []
      activities_with_profile.each do |activity|
        a = Frequency::Activity.new(activity)
        list << a.html_string_with_profile
      end
      load_html list.join('')
    else
      load_html 'No activity yet'
    end
  end

  def load_html(html)
    self.loadHTMLString("<html>#{html_head}<body><div class='activity din-medium'>#{html}</div></body></html>", baseURL:@baseURL)
  end

  def html_head
    "<head><style type='text/css'>body {margin:0 auto;text-align:left;background-color: transparent; color:white} .activity {margin: 0; font: 14.0px;}@font-face {font-family: 'DIN-Medium'; font-style: normal; font-weight: 400; src: local('DIN-Medium'), local('DIN-Medium'), url('DIN-Medium.ttf') format('truetype');} .din-medium {font-family: DIN-Medium;} .created-at {font-size:12px;color:#eee;} .item {clear:both;} .content {float:left;width:200px;} .icon {font-size:10px;text-align:center;padding-bottom:5px;width:32px;margin-right:10px;float:left;} .gem {width:32px;height:28px;margin-bottom:2px;margin-top:0px;} .purple {background:url('gem-purple.png');} .green {background:url('gem-green.png');} .orange {background:url('gem-orange.png');} .clear {clear:both;height:2px;border-bottom:solid 1px #363636;margin-bottom:5px;}</style></head>"
  end

end