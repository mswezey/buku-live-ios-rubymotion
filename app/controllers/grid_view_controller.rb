class GridViewController < UIViewController
  include BubbleWrap::KVO

  def load_photos_list
    @photos_list = App.delegate.user_photos_list
  end

  def load_friends_list
    @friends_list = App.delegate.friends
  end

  def viewDidLoad
    super
    # App.delegate.load_fan_photos_data

    @font_light = UIFont.fontWithName("DINLi", size:15)

    # create background ken burns + overlay
    bg_image1 = UIImage.imageNamed("lan-crowd1.jpg")
    bg_image2 = UIImage.imageNamed("lan-crowd2.jpeg")
    bg_kbv = KenBurnsView.alloc.initWithFrame([[0,208],[640, 640]])
    bg_kbv.animateWithImages([bg_image1, bg_image2], transitionDuration:45, loop: true, isLandscape:false)

    # TODO: set the size to fill background
    bg_overlay = UIImageView.alloc.init
    bg_overlay.image = UIImage.imageNamed("diamond.png")
    bg_overlay.frame = [[0,208],[320,570]]


    @scroll_view = UIScrollView.alloc.initWithFrame(view.bounds)
    @scroll_view.contentSize = [320, 778]
    @scroll_view.alwaysBounceVertical = false
    @scroll_view.delegate = self
    @scroll_view.addSubview(bg_kbv)
    @scroll_view.addSubview(bg_overlay)
    view.addSubview(@scroll_view)

    loadPhotoSection
    loadNowPerformingSection
    loadStillToComeSection
    loadMyPointsSection
    loadBadgesSection
    loadFriendsSection
    loadActivitySection

    @scroll_view.addSubview(@photos_view)
    @scroll_view.addSubview(@now_performing_view)
    @scroll_view.addSubview(@still_to_come_view)
    @scroll_view.addSubview(@my_points_view)
    @scroll_view.addSubview(@badges_view)
    @scroll_view.addSubview(@friends_view)
    @scroll_view.addSubview(@activity_view)
  end

  def loadPhotoSection
    @photos_view = UIView.alloc.initWithFrame([[0,0],[320, 208]])
    @photos_view.backgroundColor = UIColor.blackColor

    @photos_view.when_tapped do
      self.navigationController.pushViewController(App.delegate.photosController, animated:true)
    end

    @photos_view_label = UILabel.alloc.initWithFrame([[0,0], [320,30]])
    @photos_view_label.text = "LOADING PHOTOS"
    @photos_view_label.font = @font_light
    @photos_view_label.textColor = UIColor.whiteColor
    @photos_view_label.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    @photos_view.addSubview(@photos_view_label)

    # observe(App.delegate, :user_photos_json) do |old_value, new_value|
    #   App.alert("The label changed to #{new_value.size}")
    # end

    load_photos_slideshow
  end

  def loadNowPerformingSection
    label = UILabel.alloc.initWithFrame([[0,208], [160,30]])
    label.text = "NOW PERFORMING"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    @scroll_view.addSubview(label)

    @now_performing_view = UIView.alloc.initWithFrame([[0,238],[160, 160]]) # row 2
    @now_performing_view.backgroundColor = "#e65af5".to_color.colorWithAlphaComponent(0.42)
    @now_performing_view.when_tapped do
      App.delegate.window.rootViewController = App.delegate.tabController
    end

    artist = UIImageView.alloc.init
    artist.image = UIImage.imageNamed("diplo.png")
    artist.frame = [[0,0],[160,160]]
    @now_performing_view.addSubview(artist)
  end

  def loadStillToComeSection
    label = UILabel.alloc.initWithFrame([[160,208], [160,30]])
    label.text = "STILL TO COME"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    @scroll_view.addSubview(label)

    @still_to_come_view = UIView.alloc.initWithFrame([[160, 238],[160, 160]]) # row 2
    @still_to_come_view.backgroundColor = '#e65af5'.to_color.colorWithAlphaComponent(0.42)

    label2 = UILabel.alloc.initWithFrame([[10,10], [150,20]])
    label2.text = "AVICII"
    label2.font = @font_light
    label2.textColor = UIColor.whiteColor
    label2.backgroundColor = UIColor.clearColor
    @still_to_come_view.addSubview(label2)

    label3 = UILabel.alloc.initWithFrame([[10,30], [150,20]])
    label3.text = "ADVENTURE CLUB"
    label3.font = @font_light
    label3.textColor = UIColor.whiteColor
    label3.backgroundColor = UIColor.clearColor
    @still_to_come_view.addSubview(label3)

    label4 = UILabel.alloc.initWithFrame([[10,50], [150,20]])
    label4.text = "A-TRAK"
    label4.font = @font_light
    label4.textColor = UIColor.whiteColor
    label4.backgroundColor = UIColor.clearColor
    @still_to_come_view.addSubview(label4)
  end

  def loadMyPointsSection
    label = UILabel.alloc.initWithFrame([[0,398], [160,30]])
    label.text = "MY POINTS"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    @scroll_view.addSubview(label)

    @my_points_view = UIView.alloc.initWithFrame([[0, 428],[160, 160]]) # row 3
    @my_points_view.backgroundColor = '#39a7d2'.to_color

    points_value_label = UILabel.alloc.initWithFrame([[0,0],[160,50]])
    points_value_label.text = "52,475"
    points_value_label.textColor = UIColor.whiteColor
    points_value_label.textAlignment = UITextAlignmentCenter
    points_value_label.font = UIFont.boldSystemFontOfSize(24)
    points_value_label.backgroundColor = '#133948'.to_color
    @my_points_view.addSubview(points_value_label)

    points_gem_view = UIImageView.alloc.initWithFrame([[28,59],[105, 92]])
    points_gem_view.image = UIImage.imageNamed("gem.png")
    @my_points_view.addSubview(points_gem_view)
  end

  def loadBadgesSection
    label = UILabel.alloc.initWithFrame([[160,398], [160,30]])
    label.text = "BADGES"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    @scroll_view.addSubview(label)

    @badges_view = UIView.alloc.initWithFrame([[160, 428],[160, 160]]) # row 3
    @badges_view.backgroundColor = '#39a7d2'.to_color.colorWithAlphaComponent(0.42)
    photo_badge = UIImageView.alloc.initWithFrame([[34,19],[90, 122]])
    photo_badge.image = UIImage.imageNamed("badge-photo.png")
    @badges_view.addSubview(photo_badge)
  end

  def loadFriendsSection
    load_friends_list

    label = UILabel.alloc.initWithFrame([[0,588], [160,30]])
    label.text = "FRIENDS"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    @scroll_view.addSubview(label)

    @friends_view = UIView.alloc.initWithFrame([[0, 618],[160, 160]]) # row 4
    @friends_view.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.5)
    @friends_view.when_tapped do
      self.navigationController.pushViewController(App.delegate.friendsGridController, animated:true)
    end
    @friend = UIImageView.alloc.initWithFrame(@friends_view.bounds)
    @friends_view.addSubview(@friend)
    @current_friend = 0
    rotate_friends
  end

  def rotate_friends
    if @friends_list.all.size > 0

        UIView.animateWithDuration(1,
        animations:lambda {
          @friend.alpha = 0.0
        })

        friend = @friends_list.all[@current_friend]
        @friend.setImageWithURL(NSURL.URLWithString(friend['fb_profile_image_url']), placeholder: UIImage.imageNamed("friends.png"))
        if @friends_list.all.size > @current_friend + 1
            @current_friend += 1
        else
            @current_friend = 0
        end

        UIView.animateWithDuration(1,
        animations:lambda {
          @friend.alpha = 1.0
        })

        App.run_after(7) { rotate_friends }
    else
        App.run_after(15) { rotate_friends }
    end
  end

  def loadActivitySection
    label = UILabel.alloc.initWithFrame([[160,588], [160,30]])
    label.text = "ACTIVITY"
    label.font = @font_light
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    @scroll_view.addSubview(label)

    @activity_view = UIView.alloc.initWithFrame([[160, 618],[160, 160]]) # row 4
    @activity_view.backgroundColor = '#39a7d2'.to_color.colorWithAlphaComponent(0.42)
  end

  def viewWillAppear(animated)
    self.navigationController.setNavigationBarHidden(true)
  end

  def load_photos_slideshow
    @kbv.release if @kbv
    @kbv = KenBurnsView.alloc.initWithFrame([[0,0],[416, 208]])
    load_photos_list
    @photos = load_photos
    @kbv.animateWithImages(@photos, transitionDuration:5, loop: true, isLandscape:true)
    @photos_view.addSubview(@kbv)
    @photos_view_label.text = "PHOTOS"
    @photos_view.addSubview(@photos_view_label)
  end

  def load_photos
    photos = []
    @photos_list.all[0..5].each do |photo|
      # url_string = NSURL.URLWithString(string)
      # image_view = UIImageView.alloc.initWithFrame(@photos_view.bounds)
      # image_view.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("photo-placeholder.png"))
      # photos << image_view.image
      url = NSURL.URLWithString(photo['fan_photo']['image']['mobile_small']['url'])
      data = NSData.dataWithContentsOfURL(url)
      image = UIImage.imageWithData(data)
      photos << image
    end
    photos
  end

end