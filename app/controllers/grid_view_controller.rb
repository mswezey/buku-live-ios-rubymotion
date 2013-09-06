class GridViewController < UIViewController
  attr_accessor :carousel, :badges

  def load_photos_list
    # NSLog("START LOAD PHOTOS LIST")
    @photos_list = App.delegate.combined_photos_list
    # NSLog("END OF LOAD PHOTOS LIST")
  end

  def load_friends_list
    @friends_list = App.delegate.friends
  end

  def refreshView
    @schedule_view.reload
    @current_user.refresh
  end

  def stop_animating_pull_to_refresh
    @scroll_view.pullToRefreshView.stopAnimating
  end

  def viewDidLoad
    super
    # NSLog("VIEW DID LOAD")

    # BW::Location.get_significant do |result|
    #   p "From Lat #{result[:from].latitude}, Long #{result[:from].longitude}" rescue p "rescue from #{result[:from]}"
    #   p "To Lat #{result[:to].latitude}, Long #{result[:to].longitude}" rescue p "rescue to #{result[:to]}"
    # end

    self.navigationItem.leftBarButtonItem = App.delegate.qrButton
    self.navigationController.navigationBar.setBackgroundImage(UIImage.imageNamed("top-nav-bg.png"), forBarMetrics: UIBarMetricsDefault)

    @font_light = UIFont.fontWithName("DIN-Medium", size:17)

    @scroll_view = UIScrollView.alloc.initWithFrame(view.bounds)
    @scroll_view.contentSize = [320,995]
    @scroll_view.alwaysBounceVertical = false
    @scroll_view.delegate = self
    view.addSubview(@scroll_view)

    @scroll_view.addPullToRefreshWithActionHandler(
      Proc.new do
        App.delegate.current_user.refresh
      end
    )
    @scroll_view.pullToRefreshView.arrowColor = UIColor.whiteColor
    @scroll_view.pullToRefreshView.textColor = UIColor.whiteColor
    @scroll_view.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite

    label_row_2_bg = UIView.alloc.initWithFrame([[0,190],[320,30]])
    label_row_2_bg.backgroundColor = '#72C790'.to_color.colorWithAlphaComponent(0.5) #UIColor.blackColor.colorWithAlphaComponent(0.39)
    label_row_3_bg = UIView.alloc.initWithFrame([[0,380],[320,30]])
    label_row_3_bg.backgroundColor = '#00636B'.to_color.colorWithAlphaComponent(0.5) #UIColor.blackColor.colorWithAlphaComponent(0.39)
    label_row_4_bg = UIView.alloc.initWithFrame([[0,570],[320,30]])
    label_row_4_bg.backgroundColor = '#E00000'.to_color.colorWithAlphaComponent(0.5) #UIColor.blackColor.colorWithAlphaComponent(0.39)
    # label_row_5_bg = UIView.alloc.initWithFrame([[0,760],[320,30]])
    # label_row_5_bg.backgroundColor = '#FF7600'.to_color.colorWithAlphaComponent(0.5) #UIColor.blackColor.colorWithAlphaComponent(0.39)


    @scroll_view.addSubview(label_row_2_bg)
    @scroll_view.addSubview(label_row_3_bg)
    @scroll_view.addSubview(label_row_4_bg)
    # @scroll_view.addSubview(label_row_5_bg)
    # NSLog("BEFORE PHOTO SECTION")
    loadPhotoSection
    # NSLog("AFTER PHOTO SECTION")
    loadScheduleSection
    loadMyPointsSection
    loadBadgesSection
    loadFriendsSection
    loadActivitySection
    loadMapSection

    @scroll_view.addSubview(@photos_view)
    @scroll_view.addSubview(@schedule_view)
    @scroll_view.addSubview(App.delegate.my_points_view)
    @scroll_view.addSubview(@badges_view)
    @scroll_view.addSubview(@friends_view)
    @scroll_view.addSubview(@activity_view)
    @scroll_view.addSubview(@map_view)

    App.delegate.my_points_view.setPoints(App::Persistence['points_checkins'], App::Persistence['points_badges'], App::Persistence['points_photos'])
    # NSLog("END VIEW DID LOAD")
  end

  def loadPhotoSection
    @photos_view = UIView.alloc.initWithFrame([[0,0],[320, 190]]) # row 1
    @photos_view.backgroundColor = UIColor.blackColor

    @photos_view.when_tapped do
      self.navigationController.pushViewController(App.delegate.photosController, animated:true)
    end

    @label_row_1_bg = UIView.alloc.initWithFrame([[0,0],[320,30]])
    @label_row_1_bg.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    @photos_view.addSubview(@label_row_1_bg)

    @photos_view_label = UILabel.alloc.initWithFrame([[10,0], [310,30]])
    @photos_view_label.text = "PHOTOS"
    @photos_view_label.font = @font_light
    @photos_view_label.textColor = UIColor.whiteColor
    @photos_view_label.backgroundColor = UIColor.clearColor
    @photos_view.addSubview(@photos_view_label)

  end

  def loadScheduleSection
    # label = UILabel.alloc.initWithFrame([[10,760], [150,30]])
    # label.text = "ON STAGE"
    # label.font = @font_light
    # label.textColor = UIColor.whiteColor
    # label.backgroundColor = UIColor.clearColor
    # @scroll_view.addSubview(label)

    # label2 = UILabel.alloc.initWithFrame([[170,760], [150,30]])
    # label2.text = "UP NEXT"
    # label2.font = @font_light
    # label2.textColor = UIColor.whiteColor
    # label2.backgroundColor = UIColor.clearColor
    # @scroll_view.addSubview(label2)

    @schedule_view = App.delegate.schedule_view


    # artist = UIImageView.alloc.init
    # artist.image = UIImage.imageNamed("diplo.png")
    # artist.frame = [[0,0],[160,160]]
    # @now_performing_view.addSubview(artist)
  end

  def loadMyPointsSection
    label = UILabel.alloc.initWithFrame([[10,190], [150,30]])
    label.text = "MY POINTS"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(label)

    # moved to app delegate
    # @my_points_view = PointsView.alloc.initWithFrame([[0, 428],[160, 160]]) # row 3
    # @my_points_view.backgroundColor = '#39a7d2'.to_color
  end

  def loadBadgesSection
    label = UILabel.alloc.initWithFrame([[170,190], [150,30]])
    label.text = "MY BADGES"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(label)

    i_carousel = NSClassFromString('iCarousel')
    @badges_view = i_carousel.alloc.initWithFrame([[160, 220],[160, 160]])
    @badges_view.backgroundColor = UIColor.clearColor #'#006670'.to_color.colorWithAlphaComponent(0.42)
    @badges_view.type = 1
    @badges_view.delegate = App.delegate.badgeViewController
    @badges_view.dataSource = App.delegate.badgeViewController
    @badges_view.clipsToBounds = true
  end

  def reloadBadgeData
    @badges_view.reloadData
  end

  def loadFriendsSection
    load_friends_list

    label = UILabel.alloc.initWithFrame([[10,570], [150,30]])
    label.text = "FRIENDS"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(label)

    @friends_view = UIView.alloc.initWithFrame([[0, 600],[160, 160]]) # row 4
    @friends_view.layer.masksToBounds = true
    @friends_view.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.5)
    @friends_view.when_tapped do
      self.navigationController.pushViewController(App.delegate.friendsGridController, animated:true)
    end

    @friend = UIImageView.alloc.initWithFrame(@friends_view.bounds)
    @friend.setImageWithURL(NSURL.URLWithString(@friends_list.all.first['fb_profile_image_url']), placeholder: UIImage.imageNamed("friends.png")) if @friends_list.all && @friends_list.all.first
    @friend.setContentMode(UIViewContentModeScaleAspectFill)

    friend_layer = @friend.layer
    friend_layer.masksToBounds = true

    @next_friend = UIImageView.alloc.initWithFrame(@friends_view.bounds)
    @next_friend.setContentMode(UIViewContentModeScaleAspectFill)

    next_layer = @friend.layer
    next_layer.masksToBounds = true

    @friends_view.addSubview(@friend)
    @current_friend = 0
    rotate_friends
  end

  def rotate_friends
    if @friends_list.all && @friends_list.all.size > 0
        friend = @friends_list.all[@current_friend]
        @friend.setImageWithURL(NSURL.URLWithString(friend['fb_profile_image_url']), placeholder: UIImage.imageNamed("friends.png"))

        if @friends_list.all.size > @current_friend + 1
            @current_friend += 1
        else
            @current_friend = 0
        end

        next_friend = @friends_list.all[@current_friend]

        @next_friend.setImageWithURL(NSURL.URLWithString(next_friend['fb_profile_image_url']), placeholder: UIImage.imageNamed("friends.png"))


        # @friend.setFrame(@friends_view.bounds)


        UIView.transitionWithView(@friend, duration:0.3, options:UIViewAnimationOptionTransitionFlipFromLeft, animations: lambda {@friend.setImageWithURL(NSURL.URLWithString(next_friend['fb_profile_image_url']), placeholder: UIImage.imageNamed("friends.png"))}, completion: lambda do |finished|

        end)

        # UIView.animateWithDuration(1,
        # animations:lambda {
        #     origin = @friends_view.bounds.origin
        #     @friend.setFrame([[origin.x, origin.y], [1378, 1005]])
        # })
        App.run_after(7) { rotate_friends }
    else
        App.run_after(7) { rotate_friends }
    end
  end

  def loadActivitySection
    label = UILabel.alloc.initWithFrame([[10,380], [150,30]])
    label.text = "ACTIVITY"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(label)

    # @activity_view = UIView.alloc.initWithFrame([[160, 618],[160, 160]]) # row 4
    @activity_view = App.delegate.dashboard_activity_view # row 3

    # @activity_view.backgroundColor = '#39a7d2'.to_color.colorWithAlphaComponent(0.42)
    @activity_view.backgroundColor = UIColor.clearColor
  end

  def loadMapSection
    label = UILabel.alloc.initWithFrame([[170,570], [150,30]])
    label.text = "LIVE MAP"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(label)

    @map_view = UIView.alloc.initWithFrame([[160, 600],[160, 160]]) # row 4
    @map_view.backgroundColor = '#39a7d2'.to_color.colorWithAlphaComponent(0.42)
    live_map_thumb = UIImageView.alloc.initWithFrame([[0,0],[160, 160]])
    live_map_thumb.image = UIImage.imageNamed("live-map-button.png")
    @map_view.addSubview(live_map_thumb)

    @map_view.when_tapped do
      self.navigationController.pushViewController(App.delegate.mapController, animated:true)
    end
  end

  def viewWillAppear(animated)
    # NSLog("START VIEW WILL APPEAR")
    App.delegate.current_user.refresh if App.delegate.logged_in?
    @schedule_view.reload
    # NSLog("VWA REFRESH USER")
    App.delegate.setToolbarButtonsForDashboard
    # NSLog("VWA START LOAD PHOTOS SLIDESHOW")
    load_photos_slideshow
    # NSLog("VWA START LOAD BACKGROUND KBV")
    load_background_kbv
    # NSLog("END VIEWWILLAPPEAR")
  end

  def viewDidDisappear(animated)
    @bg_kbv.removeFromSuperview if @bg_kbv
    @kbv.removeFromSuperview if @kbv
    @bg_kbv = nil
    @kbv = nil
  end

  def load_background_kbv
    # NSLog("START LOAD BG KBV")
    unless @bg_kbv
      bg_image1 = UIImageView.alloc.init
      bg_image2 = UIImageView.alloc.init
      bg_image3 = UIImageView.alloc.init
      bg_image4 = UIImageView.alloc.init
      bg_image1.image = UIImage.imageNamed("bg3.jpeg")
      bg_image2.image = UIImage.imageNamed("bg2.jpeg")
      bg_image3.image = UIImage.imageNamed("bg1.jpeg")
      bg_image4.image = UIImage.imageNamed("bg4.jpeg")
      @bg_kbv = FUI::KenBurnsView.alloc.initWithFrame([[0,190],[320,600]])
      # NSLog("BG KBV ANIMATE WITH IMAGES")
      @bg_kbv.animateWithImages([bg_image1, bg_image2, bg_image3, bg_image4], transitionDuration:25, loop: true, isLandscape:true)

      bg_overlay = UIImageView.alloc.init
      bg_overlay.image = UIImage.imageNamed("diamond.png")
      bg_overlay.frame = [[0,190],[320,600]]

      @scroll_view.addSubview(@bg_kbv)
      @scroll_view.addSubview(bg_overlay)

      @scroll_view.sendSubviewToBack(bg_overlay)
      @scroll_view.sendSubviewToBack(@bg_kbv)
    end
    # NSLog("END LOAD BG KBV")
  end

  def load_photos_slideshow
    # NSLog("START LOAD PHOTOS SLIDESHOW")
    unless @kbv
      # NSLog("UNLESS KBV")
      @kbv = FUI::KenBurnsView.alloc.initWithFrame(@photos_view.bounds)
      # NSLog("AFTER KBV ALLOC INIT")
      load_photos_list
      # NSLog("AFTER LOAD PHOTOS LIST")
      @photos = load_photos
      # NSLog("AFTER @PHOTOS = LOAD_PHOTOS")
      @kbv.animateWithImages(@photos, transitionDuration:5, loop: true, isLandscape:true)
      @photos_view.addSubview(@kbv)
      @photos_view.addSubview(@label_row_1_bg)
      @photos_view_label.text = "PHOTOS"
      @photos_view.addSubview(@photos_view_label)
    end
  end

  def load_photos
    # NSLog("STARTING LOAD PHOTOS")
    photos = []
    # NSLog("PHOTOS = []")
    if @photos_list.all != nil
      # NSLog("IF PHOTO LIST ALL != NIL")
      @photos_list.all[0..25].each do |photo|
        photo = photo['fan_photo'] ? photo['fan_photo'] : photo['picture']
        url_string = NSURL.URLWithString(photo['image']['mobile_small']['url'])
        image_view = UIImageView.alloc.initWithFrame(@photos_view.bounds)
        image_view.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("photo-placeholder.png"))
        photos << image_view
      end
    end
    # NSLog("AFTER PHOTOS LIST LOOP")
    photos
  end

  def refresh_slideshow
    # NSLog("START REFRESH SLIDESHOW")
    # only call this if photos are empty
    @kbv.removeFromSuperview if @kbv
    @kbv = nil
    load_photos_slideshow
    # NSLog("END REFRESH SLIDESHOW")
  end

end