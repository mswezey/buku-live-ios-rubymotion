class LoginController < UIViewController

  def viewDidLoad
    self.view.backgroundColor = UIColor.whiteColor
    bg = UIImageView.alloc.initWithFrame(view.bounds)
    bg.image = UIImage.imageNamed("Default.png")
    view.addSubview(bg)
    view.addSubview(textLabel)
    view.addSubview(authButton)
    view.addSubview(moreInfoButton)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'sessionStateChanged:', name: FBSessionStateChangedNotification, object: nil)

    # Check the session for a cached token to show the proper authenticated
    # UI. However, since this is not user intitiated, do not show the login UX.
    appDelegate.openSessionWithAllowLoginUI(false)
  end

  def didReceiveMemoryWarning
    NSNotificationCenter.defaultCenter.removeObserver(self)
  end

  def dismissDialog
    self.dismissModalViewControllerAnimated(true)
  end

  # ==============
  # = Properties =
  # ==============

  def moreInfoButton
    @moreInfoButton ||= begin
      moreInfoButton = UIButton.buttonWithType(UIButtonTypeCustom)
      moreInfoButton.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.7)
      moreInfoButton.font = UIFont.fontWithName("DIN-Light", size:14)
      moreInfoButton.titleLabel.textColor = UIColor.whiteColor
      layer = moreInfoButton.layer
      layer.setBorderWidth 1
      layer.setBorderColor UIColor.lightGrayColor.CGColor
      layer.cornerRadius = 3
      moreInfoButton.frame = [[230, 400], [80, 30]]
      moreInfoButton.setTitle("More Info", forState: UIControlStateNormal)
      moreInfoButton.addTarget(self, action: "showMoreInfo", forControlEvents: UIControlEventTouchUpInside)
      moreInfoButton
    end
  end

  def showMoreInfo
    App.delegate.show_more_info_view
  end

  # The Sign-In/Sign Out button
  def authButton
    @authButton ||= begin
      _authButton = UIButton.buttonWithType(UIButtonTypeRoundedRect)

      buttonImage = UIImage.imageNamed("login-button.png")
      buttonPressedImage = UIImage.imageNamed("login-button-pressed.png")

      _authButton.setBackgroundImage(buttonImage, forState:UIControlStateNormal)
      _authButton.setBackgroundImage(buttonPressedImage, forState:UIControlStateHighlighted)


      _authButton.frame = [[50, 230], [220, 55]]
      _authButton.setTitle("Sign in With Facebook", forState: UIControlStateNormal)
      _authButton.addTarget(self, action: "authButtonAction:", forControlEvents: UIControlEventTouchUpInside)
      _authButton.font = UIFont.fontWithName("DIN-Medium", size:17)
      _authButton
    end
  end

  # Default text to show in textLabel when not signed in
  DEFAULT_TEXT = "Lights All Night LIVE! gives you chances to win backstage passes and other prizes and lets you share your festival experience like never before. Sign in to get started."

  # A UILabel showing the user's username once signed in
  def textLabel
    @textLabel ||= begin
      _textLabel = UILabel.alloc.initWithFrame([[10, 300], [300, 84]])
      _textLabel.text = DEFAULT_TEXT
      _textLabel.textAlignment = UITextAlignmentCenter
      _textLabel.textColor = UIColor.whiteColor
      _textLabel.font = UIFont.fontWithName("DIN-Medium", size:15)
      _textLabel.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.7)
      _textLabel.numberOfLines = 5
      layer = _textLabel.layer
      layer.cornerRadius = 5.0
      _textLabel
    end
  end


  # ===========
  # = Actions =
  # ===========

  # Helper method to access the app delegate
  def appDelegate
    UIApplication.sharedApplication.delegate
  end

  # The action called when the auth button is tapped
  #
  # If the user is authenticated, log out when the button is clicked.
  # If the user is not authenticated, log in when the button is clicked.
  #
  # The user has initiated a login, so call the openSession method
  # and show the login UX if necessary.
  def authButtonAction(sender)
    if FBSession.activeSession.open?
      appDelegate.closeSession
    else
      appDelegate.openSessionWithAllowLoginUI(true)
    end
  end

  # ============================
  # = Private Instance Methods =
  # ============================

  private


  def showUserInfo
    # textLabel.textColor = UIColor.blackColor
    textLabel.text = "Login Successful!"
  end

  # Reset the textLable back to gray with DEFAULT_TEXT
  def resetTextLabel
    # textLabel.textColor = UIColor.lightGrayColor
    textLabel.text      = DEFAULT_TEXT
  end

  def request(request, didFailLoadWithError:error)
    handleLoadError
  end

  def requestDidTimeout
    handleLoadError
  end

  def handleLoadError
    resetTextLabel
    authButton.hidden = false
    App.delegate.current_user.handleLoadError
  end

  def request(request, didLoadResponse: response)
    data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
    error_ptr = Pointer.new(:object)
    json = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)

    if json['status'] && json['status'] == 'success'# && json['authentication_token']

      App::Persistence['user_auth_token'] = json['authentication_token']
      App::Persistence['user_profile_image_url'] = json['profile_image_url']
      puts "user auth token saved"

      App.delegate.current_user

      url_string = NSURL.URLWithString(App.delegate.profile_image_url)
      App.delegate.profile_image_view.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("friends.png"))

      App.delegate.friends.refresh
      App.delegate.user_photos_list.refresh {App.delegate.gridViewController.refresh_slideshow}

      dismissDialog

      unless App::Persistence['asked_user_for_publish_permissions']

        App.run_after(3) {
          FBSession.activeSession.reauthorizeWithPublishPermissions(["publish_checkins", "publish_stream"],
                                  defaultAudience:FBSessionDefaultAudienceFriends,
                                  completionHandler: lambda do |session, error|
                                    App::Persistence['asked_user_for_publish_permissions'] = true
                                    puts "finished asking"
                                    puts "session: #{session.permissions}"
                                  end)
        }


      end
    else
      puts "user auth not saved"
      resetTextLabel
      authButton.setTitle("Sign in with Facebook", forState: UIControlStateNormal)
      App.alert("Login Failed")
    end

  end

  def authenticateWithServer
    puts "requesting user auth token from facebook access token"
    access_token = FBSession.activeSession.accessToken
    puts "init"
    authentication = Frequency::Authentication.new(access_token)
    puts "authenticate"
    FRequest.new(POST, authentication.path, authentication.params, self)
  end

  # Called when the FBSessionStateChangedNotification is pushed out
  # Changed the text on the authButton and updates the textLabel
  def sessionStateChanged(notification)
    puts "session state changed called.  Session open? #{FBSession.activeSession.open?}"
    puts "permision to post? #{FBSession.activeSession.permissions.include?("publish_stream") && FBSession.activeSession.permissions.include?("publish_checkins")}"
    if FBSession.activeSession.open?
      showUserInfo
      authenticateWithServer
      authButton.hidden = true
    else
      resetTextLabel
      authButton.hidden = false
    end
  end

end