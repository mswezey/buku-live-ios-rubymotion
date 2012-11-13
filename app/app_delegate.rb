class AppDelegate

  ::FBSessionStateChangedNotification = "#{App.identifier}:FBSessionStateChangedNotification"

  # The extra permissions we're requesting from Facebook
  # By default, the basics are already provided https://developers.facebook.com/docs/reference/login/basic-info/
  FBPermissions = %w{ user_birthday user_hometown user_location email}

  # ==============
  # = Properties =
  # ==============

  def dashboardController
    @dashboardController ||= DashboardController.alloc.initWithTabBar
  end

  def friendsViewController
    @friendsViewController ||= FriendsViewController.alloc.initWithTabBar
  end

  def mapController
    @mapController ||= MapController.alloc.initWithTabBar
  end

  def photosController
    @photosController ||= PhotosController.alloc.initWithTabBar
  end

  def photosNavController
    @photosNavController ||= UINavigationController.alloc.initWithRootViewController(photosController)
  end

  def gridController
    @gridController ||= GridViewController.new
  end

  def gridNavController
    @gridNavController ||= UINavigationController.alloc.initWithRootViewController(gridController)
  end

  def userController
    @userController ||= UserController.alloc.initWithTabBar
  end

  def tabController
    @tabController ||= UITabBarController.alloc.init
    @tabController.viewControllers = [dashboardController, photosNavController, friendsViewController, mapController, scannerViewController, userController]
    @tabController
  end

  def scannerViewController
    @scannerViewController ||= ScannerViewController.alloc.initWithTabBar
  end

  def loginController
    @loginController ||= LoginController.alloc.init
  end

  def window
    @window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
  end

  def frequency_app_uri
    # 'http://10.0.1.17:3000'
  'http://www.lan-live.com'
  end

  def load_friends_list_data
    return false unless App::Persistence['user_auth_token']
    data = {auth_token: App::Persistence['user_auth_token']}
    BW::HTTP.get("#{frequency_app_uri}/my-friends.json", {payload: data}) do |response|
      if response.ok?
        json_string = response.body.to_str
        File.open("#{App.documents_path}/friends.json", "w") {|f| f.write(json_string)}
      else
        # TODO: handle failure
      end
    end
  end

  def load_fan_photos_data
    return false unless App::Persistence['user_auth_token']
    data = {auth_token: App::Persistence['user_auth_token']}
    BW::HTTP.get("#{frequency_app_uri}/api/mobile/fan_photos", {payload: data}) do |response|
      if response.ok?
        json_string = response.body.to_str
        File.open("#{App.documents_path}/fan_photos.json", "w") {|f| f.write(json_string)}
      else
        # TODO: handle failure
      end
    end
  end

  # =============
  # = Callbacks =
  # =============

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    window.rootViewController = gridController
    # window.rootViewController = App::Persistence['user_auth_token'] ? tabController : loginController
    window.rootViewController.wantsFullScreenLayout = true
    window.makeKeyAndVisible
    true
  end

  def applicationDidBecomeActive(application)
    # We need to properly handle activation of the application with regards to SSO
    # (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    FBSession.activeSession.handleDidBecomeActive
  end

  def applicationWillTerminate(application)
    # Kill the Facebook session when the application terminates
    FBSession.activeSession.close
  end

  # ===========================================================================================================
  # = Facebook Methods - https://developers.facebook.com/docs/howtos/login-with-facebook-using-ios-sdk/#setup =
  # ===========================================================================================================

  # Callback for session changes.
  # If the statei s FBSessionStateOpen, do nothing...
  # If the state is FBSessionStateClosed or FBSessionStateClosedLoginFailed, close the Facebook session
  #
  # Pushes out a FBSessionStateChangedNotification to any objects who are observing
  #
  # Finally, if there's an error object, shows an alert dialogue with the error description
  def sessionStateChanged(session, state: state, error: error)
    case state
    when FBSessionStateOpen
      unless error
        # We have a valid session
        NSLog("User session found")
      end
    when FBSessionStateClosed, FBSessionStateClosedLoginFailed
      FBSession.activeSession.closeAndClearTokenInformation
    end

    NSNotificationCenter.defaultCenter.postNotificationName(FBSessionStateChangedNotification, object: session)

    UIAlertView.alloc.initWithTitle("Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil).show if error
  end


  # Opens a Facebook session and optionally shows the login UX.
  def openSessionWithAllowLoginUI(allowLoginUI)
    completionBlock = Proc.new do |session, state, error|
      sessionStateChanged(session, state: state, error: error)
    end
    FBSession.openActiveSessionWithReadPermissions(FBPermissions, allowLoginUI: allowLoginUI, completionHandler: completionBlock)
  end

  # If we have a valid session at the time of openURL call, we handle
  # Facebook transitions by passing the url argument to handleOpenURL (< iOS 6)
  #
  # Returns a Boolean value
  def application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    # attempt to extract a token from the url
    FBSession.activeSession.handleOpenURL(url)
  end

  # Close the Facebook session when done
  def closeSession
    FBSession.activeSession.closeAndClearTokenInformation
    window.rootViewController = loginController
    App::Persistence['user_auth_token'] = nil
  end

end