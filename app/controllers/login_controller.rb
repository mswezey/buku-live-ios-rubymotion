class LoginController < UIViewController

  # def initWithTabBar
  #   me = init
  #   anImage = UIImage.imageNamed("dashboard.png")
  #   me.tabBarItem = UITabBarItem.alloc.initWithTitle("Login", image:anImage, tag:1)
  #   me
  # end

  def viewDidLoad
    puts "LoginController view did load"
    self.view.backgroundColor = UIColor.whiteColor
    view.addSubview(textLabel)
    view.addSubview(authButton)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'sessionStateChanged:', name: FBSessionStateChangedNotification, object: nil)

    # Check the session for a cached token to show the proper authenticated
    # UI. However, since this is not user intitiated, do not show the login UX.
    appDelegate.openSessionWithAllowLoginUI(false)
  end

  def didReceiveMemoryWarning
    NSNotificationCenter.defaultCenter.removeObserver(self)
  end

  # ==============
  # = Properties =
  # ==============

  # The Sign-In/Sign Out button
  def authButton
    @authButton ||= begin
      _authButton = UIButton.buttonWithType(UIButtonTypeRoundedRect)
      _authButton.frame = [[50, 200], [220, 44]]
      _authButton.setTitle("Sign in With Facebook", forState: UIControlStateNormal)
      _authButton.addTarget(self, action: "authButtonAction:", forControlEvents: UIControlEventTouchUpInside)
      _authButton
    end
  end

  # Default text to show in textLabel when not signed in
  DEFAULT_TEXT = "Sign in to get started"

  # A UILabel showing the user's username once signed in
  def textLabel
    @textLabel ||= begin
      _textLabel = UILabel.alloc.initWithFrame([[50, 140], [220, 44]])
      _textLabel.text = DEFAULT_TEXT
      _textLabel.textAlignment = UITextAlignmentCenter
      _textLabel.textColor = UIColor.lightGrayColor
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

  # Populate the textField with the user's username if successfully signed in
  def showUserInfo
    textLabel.textColor = UIColor.blackColor
    textLabel.text = "Login Successful!"
    # FBRequest.requestForMe.startWithCompletionHandler(lambda do |connection, user, error|
    #   if error.nil?
    #     NSLog("#{user.inspect}")
    #     textLabel.textColor = UIColor.blackColor
    #     textLabel.text = "#{user[:name]}"
    #   end
    # end)
  end

  # Reset the textLable back to gray with DEFAULT_TEXT
  def resetTextLabel
    textLabel.textColor = UIColor.lightGrayColor
    textLabel.text      = DEFAULT_TEXT
  end

  def dismissDialog
    self.dismissModalViewControllerAnimated(true)
  end

  def authenticateWithServer
    puts "requesting user auth token from facebook access token"
    access_token = FBSession.activeSession.accessToken
    puts "init"
    authentication = Frequency::Authentication.new(access_token)
    puts "authenticate"
    BW::HTTP.post(authentication.url, {payload: authentication.payload}) do |response|
      if response.ok?
        puts "response ok"
        json = BW::JSON.parse(response.body.to_str)
        if json['status'] && json['status'] == 'success'# && json['authentication_token']

          App::Persistence['user_auth_token'] = json['authentication_token']
          App::Persistence['user_profile_image_url'] = json['profile_image_url']
          puts "user auth token saved"

          url_string = NSURL.URLWithString(App.delegate.profile_image_url)
          App.delegate.profile_image_view.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("friends.png"))
          App.delegate.friends.refresh
          App.delegate.user_photos_list.refresh {App.delegate.gridController.refresh_slideshow}
          # App.delegate.window.rootViewController = App.delegate.gridNavController
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
          App.alert("Login Failed")
        end
      else
        puts "response not ok"
        App.alert("Login Failed due to server error. Please Try Again.")
      end
    end
  end

  # Called when the FBSessionStateChangedNotification is pushed out
  # Changed the text on the authButton and updates the textLabel
  def sessionStateChanged(notification)
    puts "session state changed called.  Session open? #{FBSession.activeSession.open?}"
    puts "permision to post? #{FBSession.activeSession.permissions.include?("publish_stream") && FBSession.activeSession.permissions.include?("publish_checkins")}"
    if FBSession.activeSession.open?
      showUserInfo
      authenticateWithServer
      authButton.setTitle("Sign out", forState: UIControlStateNormal)
    else
      resetTextLabel
      authButton.setTitle("Sign in with Facebook", forState: UIControlStateNormal)
    end
  end

end