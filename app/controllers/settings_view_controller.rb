class SettingsViewController < UIViewController

  def viewDidLoad
    self.title = "Settings"
    @settings_view = UIWebView.alloc.initWithFrame(view.bounds)
    @settings_view.backgroundColor = '#133948'.to_color
    @settings_view.setOpaque false
    # @settings_view.suppressesIncrementalRendering = true
    self.view.addSubview @settings_view
    loadRequest
  end

  def viewWillAppear(animated)
    # @settings_view.reload
    loadRequest
  end

  def loadRequest
    fullURL = "#{App.delegate.frequency_app_uri}#{App.delegate.current_user.settings_path}"
    url = NSURL.URLWithString(fullURL)
    requestObj = NSURLRequest.requestWithURL(url)
    @settings_view.loadRequest(requestObj)
  end

end