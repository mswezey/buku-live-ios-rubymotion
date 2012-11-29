class FriendDetailViewController < UIViewController
  attr_accessor :friend_id, :profile_image_url

  def rotate_photos
    if @friends_list.all.size > 0

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

  def friendDidLoad
    puts "friend did load"
    @points_view.setPoints(@friend.attributes["points_from_checkins"], @friend.attributes["points_from_badges"], @friend.attributes["points_from_photos"])
    @name_label.text = @friend.attributes['name'].upcase

    @photos_list = @friend.attributes["recent_fan_photos"]
    if @photos_list.size > 0
      @photos = []
      @photos_list.each do |photo|
        url_string = NSURL.URLWithString(photo['fan_photo']['image']['mobile_small']['url'])
        image_view = UIImageView.alloc.initWithFrame(@photos_view.frame)
        image_view.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("photo-placeholder.png"))
        @photos << image_view
      end
      @kbv = FUI::KenBurnsView.alloc.initWithFrame(@photos_view.bounds)
      @kbv.animateWithImages(@photos, transitionDuration:5, loop: true, isLandscape:true)
      @photos_view.addSubview(@kbv)
    end
  end

  def viewDidLoad
    @friend = Frequency::Friend.new(@friend_id)
    @friend.refresh { friendDidLoad }


    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(App.delegate.navToolbar)

    @font_light = UIFont.fontWithName("DIN-Light", size:17)

    @scroll_view = UIScrollView.alloc.initWithFrame(view.bounds)
    @scroll_view.contentSize = [320, 730]
    view.addSubview(@scroll_view)

    background = UIImageView.alloc.initWithFrame([[0,190],[810,540]])
    background.image = UIImage.imageNamed("lan-crowd1.jpg")
    @scroll_view.addSubview(background)

    bg_overlay = UIImageView.alloc.init
    bg_overlay.image = UIImage.imageNamed("diamond.png")
    bg_overlay.frame = [[0,190],[320,570]]
    @scroll_view.addSubview(bg_overlay)

    label_row_1_bg = UIView.alloc.initWithFrame([[0,0],[320,30]])
    label_row_1_bg.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    label_row_2_bg = UIView.alloc.initWithFrame([[0,190],[320,30]])
    label_row_2_bg.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    label_row_3_bg = UIView.alloc.initWithFrame([[0,380],[320,30]])
    label_row_3_bg.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    @scroll_view.addSubview(label_row_1_bg)
    @scroll_view.addSubview(label_row_2_bg)
    @scroll_view.addSubview(label_row_3_bg)


    @name_label = UILabel.alloc.initWithFrame([[10,0],[150,30]])
    @name_label.font = @font_light
    @name_label.textColor = UIColor.whiteColor
    @name_label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(@name_label)

    @profile_picture = UIImageView.alloc.initWithFrame([[0,30],[160,160]])
    @profile_picture.setImageWithURL(NSURL.URLWithString(@profile_image_url), placeholder: UIImage.imageNamed("friends.png")) # TODO: Replace placeholder image
    @scroll_view.addSubview(@profile_picture)

    points_label = UILabel.alloc.initWithFrame([[170,0],[150,30]])
    points_label.text = "POINTS"
    points_label.font = @font_light
    points_label.textColor = UIColor.whiteColor
    points_label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(points_label)

    @points_view = PointsView.alloc.initWithFrame([[160,30],[160,160]])
    @scroll_view.addSubview(@points_view)

    badges_label = UILabel.alloc.initWithFrame([[10,190],[150,30]]) # row 2
    badges_label.text = "BADGES"
    badges_label.font = @font_light
    badges_label.textColor = UIColor.whiteColor
    badges_label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(badges_label)

    badges_view = UIView.alloc.initWithFrame([[0,220],[160,160]])
    badges_view.backgroundColor = '#39a7d2'.to_color.colorWithAlphaComponent(0.42)
    @scroll_view.addSubview(badges_view)

    photo_badge = UIImageView.alloc.initWithFrame([[34,19],[90, 122]])
    photo_badge.image = UIImage.imageNamed("badge-photo.png")
    badges_view.addSubview(photo_badge)

    photos_label = UILabel.alloc.initWithFrame([[170,190],[150,30]])  # row 2
    photos_label.text = "PHOTOS"
    photos_label.font = @font_light
    photos_label.textColor = UIColor.whiteColor
    photos_label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(photos_label)

    @photos_view = UIView.alloc.initWithFrame([[160,220],[160,160]])
    @photos_view.backgroundColor = '#39a7d2'.to_color

    @scroll_view.addSubview(@photos_view)

    activity_label = UILabel.alloc.initWithFrame([[10,380],[310,30]]) # row 3
    activity_label.text = "ACTIVITY"
    activity_label.font = @font_light
    activity_label.textColor = UIColor.whiteColor
    activity_label.backgroundColor = UIColor.clearColor
    @scroll_view.addSubview(activity_label)

  end

  def viewWillAppear(animated)
    # App.delegate.setToolbarButtonsForOther
    setToolbarButtons
  end

  def setToolbarButtons
    buttons = []

    flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
    compose_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCompose, target:self, action:'writeMessage')

    buttons << flexibleSpace
    buttons << App.delegate.points
    buttons << compose_button

    App.delegate.navToolbar.setItems(buttons, animated:false)
  end

  def writeMessage
    App.alert("Write Message")
  end

end