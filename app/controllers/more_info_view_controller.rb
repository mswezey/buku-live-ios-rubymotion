class MoreInfoViewController < UIViewController

  def viewDidLoad
    @info_view = UIWebView.alloc.initWithFrame(view.bounds)
    @info_view.backgroundColor = '#133948'.to_color
    @info_view.setOpaque false
    # @info_view.suppressesIncrementalRendering = true
    self.view.addSubview @info_view
    self.view.addSubview closeButton
    loadRequest
  end

  def viewWillAppear(animated)
    # @info_view.reload
    loadRequest
  end

  def loadRequest
    fullURL = "#{App.delegate.frequency_app_uri}/api/mobile/more_info#{ "?auth_token=" + App::Persistence['user_auth_token'] if App.delegate.logged_in? }"
    url = NSURL.URLWithString(fullURL)
    requestObj = NSURLRequest.requestWithURL(url)
    @info_view.loadRequest(requestObj)
  end

  def closeButton
    @closeButton ||= begin
      closeButton = UIButton.buttonWithType(UIButtonTypeCustom)
      closeButton.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.7)
      closeButton.font = UIFont.fontWithName("DIN-Light", size:14)
      closeButton.titleLabel.textColor = UIColor.whiteColor
      layer = closeButton.layer
      layer.setBorderWidth 1
      layer.setBorderColor UIColor.lightGrayColor.CGColor
      layer.cornerRadius = 3
      closeButton.frame = [[260, 10], [50, 26]]
      closeButton.setTitle("Back", forState: UIControlStateNormal)
      closeButton.addTarget(self, action: "returnToLoginScreen", forControlEvents: UIControlEventTouchUpInside)
      closeButton.hidden = true
      closeButton
    end
  end

  def showCloseButton
    closeButton.hidden = false
  end

  def hideCloseButton
    closeButton.hidden = true
  end

  def returnToLoginScreen
    hideCloseButton
    self.dismissModalViewControllerAnimated(true)
    App.run_after(0.8) {App.delegate.show_login_modal}
  end

end