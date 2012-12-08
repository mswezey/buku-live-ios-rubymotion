class FriendDetailViewController < UIViewController
  attr_accessor :friend_id, :profile_image_url

  def viewDidLoad
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

    photo_badge = UIImageView.alloc.initWithFrame([[34,19],[90, 107]])
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

  def viewDidDisappear(animated)
    @activity_list.removeFromSuperview if @activity_list
  end

  def viewWillAppear(animated)
    @name_label.text = "LOADING"

    @activity_list = ActivityView.alloc.initWithFrame([[10,415],[310,270]])
    @scroll_view.addSubview(@activity_list)

    @points_view.resetPoints
    if (@photos_view.subviews.count > 0)
      @photos_view.subviews.objectAtIndex(0).removeFromSuperview
    end
    @friend = Frequency::Friend.new(@friend_id)
    @friend.refresh

    @profile_picture.setImageWithURL(NSURL.URLWithString(@profile_image_url), placeholder: UIImage.imageNamed("friends.png")) # TODO: Replace placeholder image
    @profile_picture.setContentMode(UIViewContentModeScaleAspectFill)

    profile_picture_layer = @profile_picture.layer
    profile_picture_layer.masksToBounds = true

    setToolbarButtons
  end

  def friendDidLoad
    puts "friend did load"

    @profile_picture.setImageWithURL(NSURL.URLWithString(@friend.attributes['fb_profile_image_url']), placeholder: UIImage.imageNamed("friends.png")) # TODO: Replace placeholder image

    @points_view.setPoints(@friend.attributes["points_from_checkins"], @friend.attributes["points_from_badges"], @friend.attributes["points_from_photos"])

    @name_label.text = @friend.attributes['name'].upcase

    @activity_list.activities = @friend.attributes['activities']

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