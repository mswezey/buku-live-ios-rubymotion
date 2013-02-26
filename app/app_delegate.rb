class AppDelegate

  attr_accessor :photographers, :unauthorized_count, :map_annotations

  ::FBSessionStateChangedNotification = "#{App.identifier}:FBSessionStateChangedNotification"

  # The extra permissions we're requesting from Facebook
  # By default, the basics are already provided https://developers.facebook.com/docs/reference/login/basic-info/
  FBPermissions = %w{ user_birthday user_hometown user_location email user_likes user_interests user_photos}

  # ==============
  # = Properties =
  # ==============

  def notificationController
    @notificationController ||= begin
      notificationController = SJNotificationViewController.alloc.initWithNibName("SJNotificationViewController", bundle:nil)
      notificationController.setParentView App.delegate.window
      notificationController.setNotificationTitle "Loading"
      notificationController.backgroundColor = '#39a7d2'.to_color.colorWithAlphaComponent(0.42)
      notificationController.setShowSpinner true
    end
  end

  def errorNotificationController
    @errorNotificationController ||= begin
      notificationController = SJNotificationViewController.alloc.initWithNibName("SJNotificationViewController", bundle:nil)
      notificationController.setParentView App.delegate.window
      notificationController.setNotificationTitle ""
      notificationController.backgroundColor = UIColor.redColor.colorWithAlphaComponent(0.42)
      notificationController.setShowSpinner false
      notificationController.setTapTarget(nil, selector:nil)
      warning_icon = UIImageView.alloc.initWithFrame([[12,8],[28,24]])
      warning_icon.image = UIImage.imageNamed("warning.png")
      notificationController.view.addSubview(warning_icon)
      label = notificationController.view.subviews.first
      label.frame = [[50, 11], [290, 21]]
      notificationController
    end
  end

  def dashboard_activity_view
    @dashboard_activity_view ||= ActivityView.alloc.initWithFrame([[0,410],[320,160]])
  end

  def schedule_view
    @schedule_view ||= ScheduleView.alloc.initWithFrame([[0,790],[320, 160]]) # row 5
  end

  def friendDetailViewController
    @friendDetailViewController ||= FriendDetailViewController.alloc.init
  end

  def friendsGridController
    @friendsGridController ||= FriendsGridController.alloc.init
  end

  def friendBadgeViewController
    @friendBadgeViewController ||= FriendBadgeViewController.alloc.init
  end

  def badgeViewController
    @badgeViewController ||= BadgeViewController.alloc.init
  end

  def mapController
    @mapController ||= MapController.alloc.init
  end

  def photosController
    @photosController ||= PhotosController.alloc.init
  end

  def photosNavController
    @photosNavController ||= UINavigationController.alloc.initWithRootViewController(photosController)
  end

  def gridViewController
    @gridViewController ||= GridViewController.new
  end

  def gridNavController
    @gridNavController ||= UINavigationController.alloc.initWithRootViewController(gridViewController)
  end

  def scannerViewController
    @scannerViewController ||= ScannerViewController.alloc.init
  end

  def loginController
    @loginController ||= begin
      login_controller = LoginController.alloc.init
      login_controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal
      login_controller
    end
  end

  def server
    @server ||= Server.new(frequency_app_uri)
  end

  def window
    @window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
  end

  def frequency_app_uri
    Frequency::FREQUENCY_APP_URL
  end

  def load_photographers
    @photographers ||= Frequency::PhotographerList.new
  end

  def load_map_annotations
    @map_annotations ||= Frequency::MapAnnotationList.new
  end

  def user_photos_list
    NSLog("USER PHOTOS NEW")
    @user_photos_list ||= Frequency::FanPhotoList.new
    NSLog("AFTER USER PHOTOS NEW")
    @user_photos_list
  end

  def pro_photos_list
    @pro_photos_list ||= Frequency::ProPhotoList.new
    @pro_photos_list
  end

  def combined_photos_list
    @combined_photos_list ||= Frequency::CombinedPhotoList.new
    @combined_photos_list
  end

  def load_user_photos_list
    NSLog("LOAD USER PHOTOS")
    combined_photos_list
    @combined_photos_list.refresh if logged_in?
    NSLog("AFTER LOAD USER PHOTOS")
  end

  def friends
    @friends ||= Frequency::FriendList.new
    @friends
  end

  def load_friends_list
    friends.refresh if logged_in?
  end

  def logged_in?
    App::Persistence['user_auth_token'] ? true : false
  end

  def show_login_modal
    window.rootViewController.presentModalViewController(loginController, animated:true ) unless window.rootViewController.visibleViewController == loginController
  end

  def qrButton
    @qrButton ||= begin

      button = UIButton.buttonWithType(UIButtonTypeCustom)
      buttonFrame = button.frame
      buttonFrame.size.width = 34
      buttonFrame.size.height = 34

      buttonImage = UIImage.imageNamed("qr-icon.png")
      buttonPressedImage = UIImage.imageNamed("qr-icon-pressed.png")

      button.setFrame(buttonFrame)
      button.addTarget(self, action:"showQrReader", forControlEvents:UIControlEventTouchUpInside)

      button.setBackgroundImage(buttonImage, forState:UIControlStateNormal)
      button.setBackgroundImage(buttonPressedImage, forState:UIControlStateHighlighted)

      buttonItem = UIBarButtonItem.alloc.initWithCustomView(button)
      buttonItem
    end
  end

  def showQrReader
    gridNavController.pushViewController(App.delegate.scannerViewController, animated:true)
  end

  def menuButton
    @menuButton ||= begin

      button = UIButton.buttonWithType(UIButtonTypeCustom)
      buttonFrame = button.frame
      buttonFrame.size.width = 44.0
      buttonFrame.size.height = 44.0

      buttonImage = UIImage.imageNamed("nav-bar-menu.png") # stretchableImageWithLeftCapWidth:5 topCapHeight:0];
      buttonPressedImage = UIImage.imageNamed("nav-bar-menu-pressed.png")# stretchableImageWithLeftCapWidth:5 topCapHeight:0]

      button.setFrame(buttonFrame)
      button.addTarget(self, action:"showMenu", forControlEvents:UIControlEventTouchUpInside)

      button.setBackgroundImage(buttonImage, forState:UIControlStateNormal)
      button.setBackgroundImage(buttonPressedImage, forState:UIControlStateHighlighted)

      buttonItem = UIBarButtonItem.alloc.initWithCustomView(button)
      buttonItem
    end
  end

  def showMenu
    popupQuery = UIActionSheet.alloc.initWithTitle("", delegate:self, cancelButtonTitle:'Cancel', destructiveButtonTitle:nil, otherButtonTitles:"View Profile", "Edit Settings", "More Info", "Logout", nil)
    popupQuery.delegate = self
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent
    popupQuery.showInView(gridViewController.view)
  end

  def actionSheet(actionSheet, clickedButtonAtIndex:buttonIndex)
    case buttonIndex
      when 0
        show_user_profile
      when 1
        show_edit_settings
      when 2
        show_more_info_view
      when 3
        App.delegate.closeSession
        App.delegate.show_login_modal
      when 4
        # cancelled
    end
  end

  def navToolbar
    @navToolbar ||= begin
      toolbar = UIToolbar.alloc.initWithFrame([[0, 0],[246, 45]])
      toolbar.setBackgroundImage(UIImage.imageNamed("clear-tb-bg.png"), forToolbarPosition:UIToolbarPositionAny, barMetrics:UIBarMetricsDefault)
      # toolbar.tintColor = UIColor.clearColor
      # toolbar.translucent = true
    end
  end

  def setToolbarButtonsForDashboard
    buttons = []

    flexibleSpaceLeft = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

    negativeSpacer12 = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil)
    negativeSpacer12.width = -12

    negativeSpacer7 = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil)
    negativeSpacer7.width = -7

    negativeSpacer5 = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil)
    negativeSpacer5.width = -5

    buttons << flexibleSpaceLeft

    buttons << negativeSpacer7

    buttons << points
    buttons << negativeSpacer7

    buttons << profile
    buttons << negativeSpacer12

    buttons << menuButton
    buttons << negativeSpacer12
    buttons << negativeSpacer5

    navToolbar.setItems(buttons, animated:false)
    # navToolbar.setFrame([[0, 0],[246, 45]])
  end

  def setToolbarButtonsForOther
    buttons = []

    flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

    buttons << flexibleSpace
    buttons << points
    buttons << flexibleSpace

    navToolbar.setItems(buttons, animated:false)
    # navToolbar.setFrame([[0, 0],[158, 45]])
  end

  def points
    @points ||= begin
      points_image = UIImageView.alloc.initWithFrame([[0,0],[158,60]])
      points_image.layer.masksToBounds = true
      points_image.layer.cornerRadius = 3
      points_image.when_tapped do
        current_user.refresh if logged_in?
      end
      points_image.image = UIImage.imageNamed("nav-bar-points.png")
      points_image.addSubview(points_label)
      points = UIBarButtonItem.alloc.initWithCustomView(points_image)
      points
    end
  end

  def points_label
    @points_label ||= begin
      points_label = UILabel.alloc.initWithFrame([[4,2],[150,44]])
      points_label.text = App::Persistence['points_total'] || "0"
      points_label.font = UIFont.fontWithName("DIN-Bold", size:24)
      points_label.adjustsFontSizeToFitWidth = true
      points_label.textColor = '#DE0002'.to_color
      points_label.backgroundColor = UIColor.clearColor
      points_label.textAlignment = UITextAlignmentCenter
      points_label
    end
  end

  def profile
    # profile picture for nav bar
    @profile ||= begin
      profile = UIBarButtonItem.alloc.initWithCustomView(profile_image_view)
      profile
    end
  end

  def profile_image_view
    @profile_image_view ||= begin
      profile_image_view = UIImageView.alloc.initWithFrame([[0,0],[44,43]])
      profile_image_view.layer.masksToBounds = true
      url_string = NSURL.URLWithString(profile_image_url)
      profile_image_view.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("friends.png"))
      profile_image_view.when_tapped do
        show_user_profile
      end
      profile_image_view
    end
  end

  def show_user_profile
    if logged_in?
      detail_view_controller = App.delegate.friendDetailViewController
      detail_view_controller.friend_id = current_user.id
      detail_view_controller.profile_image_url = current_user.profile_image_url
      App.delegate.gridNavController.pushViewController(detail_view_controller, animated:true)
    end
  end

  def show_edit_settings
    if logged_in?
      view_controller = App.delegate.settings_view_controller
      App.delegate.gridNavController.pushViewController(view_controller, animated:true)
    end
  end

  def settings_view_controller
    @settings_view_controller ||= SettingsViewController.alloc.init
  end

  def show_more_info_view
    view_controller = App.delegate.more_info_view_controller
    if window.rootViewController.visibleViewController == loginController
      loginController.dismissModalViewControllerAnimated(false)
      view_controller.showCloseButton
      window.rootViewController.presentModalViewController(view_controller, animated:true )
    else
      App.delegate.gridNavController.pushViewController(view_controller, animated:true)
    end
  end

  def more_info_view_controller
    @more_info_view_controller ||= MoreInfoViewController.alloc.init
  end

  def my_points_view
    @my_points_view ||= begin
      points_view = PointsView.alloc.initWithFrame([[0, 220],[160, 160]]) # row 2
      points_view
    end
  end

  def profile_image_url
    App::Persistence['user_profile_image_url']
  end

  def current_user
    NSLog("INITIALIZE CURRENT USER")
    @current_user ||= Frequency::User.new
  end

  def unauthorized_count
    App::Persistence['unauthorized_count'] || 0
  end

  def unauthorized_count=(unauthorized_count)
    App::Persistence['unauthorized_count'] = unauthorized_count
  end

  # =============
  # = Callbacks =
  # =============

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    server # initialize Server communications
    App::Persistence['points_checkins'] = 0 unless App::Persistence['points_checkins']
    App::Persistence['points_photos'] = 0 unless App::Persistence['points_photos']
    App::Persistence['points_badges'] = 0 unless App::Persistence['points_badges']

    current_user if logged_in?

    load_user_photos_list
    load_friends_list
    NSLog("BEFORE rootViewController")
    window.rootViewController = gridNavController
    window.rootViewController.wantsFullScreenLayout = true
    window.makeKeyAndVisible

    gridNavController.navigationBar.setBackgroundImage(UIImage.imageNamed("top-nav-bg.png"), forBarMetrics: UIBarMetricsDefault)

    setToolbarButtonsForDashboard
    gridViewController.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(navToolbar)

    App.run_after(0.5) {show_login_modal} unless logged_in?

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

  # Close the Facebook session and clear user info on logout
  def closeSession
    FBSession.activeSession.closeAndClearTokenInformation
    App::Persistence['user_auth_token'] = nil
    App::Persistence['user_profile_image_url'] = nil
    App::Persistence['user_fb_profile_image_url'] = nil
    App::Persistence['user_id'] = nil
    App::Persistence['points_total'] = "0"
    App::Persistence['asked_user_for_publish_permissions'] = nil
    dashboard_activity_view.activities = []
    @user_photos_list.all = []
    @friends.all = []

    File.open("#{App.documents_path}/friends.json", "w") {|f| f.write("[]")}
    File.open("#{App.documents_path}/fan_photos.json", "w") {|f| f.write("[]")}
    File.open("#{App.documents_path}/pro_photos.json", "w") {|f| f.write("[]")}
  end

end