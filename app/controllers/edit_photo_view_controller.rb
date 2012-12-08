class EditPhotoViewController < UIViewController
  attr_accessor :image, :photo, :pro_photo

  def initWithImage(aImage, photo:photo)
    @font_light = UIFont.fontWithName("DIN-Light", size:18)
    me = init
    self.image = aImage
    self.photo = photo
    if photo['taken_by']
      self.pro_photo = false
    else
      self.pro_photo = true
    end
    me
  end

  def viewDidLoad
    super

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(App.delegate.navToolbar)

    @scrollView = UIScrollView.alloc.initWithFrame(view.bounds)
    @scrollView.delegate = self
    @scrollView.backgroundColor = UIColor.grayColor
    self.view.addSubview @scrollView

    puts self.pro_photo
    frame = self.pro_photo ? [[5, 32], [310, 213]] : [[10, 22], [300, 300]]

    photoImageView = UIImageView.alloc.initWithFrame(frame)
    photoImageView.setBackgroundColor(UIColor.blackColor)
    photoImageView.setImage(self.image)
    photoImageView.setContentMode(UIViewContentModeScaleAspectFill)

    layer = photoImageView.layer
    layer.masksToBounds = true
    layer.shadowRadius = 3.0
    layer.shadowOffset = [0.0, 2.0]
    layer.shadowOpacity = 0.5
    layer.shouldRasterize = true

    if self.pro_photo && photo['users'].size > 0
      tagged = []

      containerView = UIView.alloc.initWithFrame([[5,245 + tagged.size * 54], [310, 54]])
      containerView.backgroundColor = UIColor.whiteColor
      tagged_label = UILabel.alloc.initWithFrame [[13, 10], [180, 30]]
      tagged_label.font = UIFont.fontWithName("DIN-Light", size:24)
      tagged_label.backgroundColor = UIColor.clearColor
      tagged_label.text = "In this photo"
      containerView.addSubview tagged_label

      tagged << containerView

      photo['users'].each do |user|
        containerView = UIView.alloc.initWithFrame([[5,245 + tagged.size * 54], [310, 54]])
        containerView.backgroundColor = UIColor.whiteColor
        profile_image_view = UIImageView.alloc.initWithFrame([[4,4],[45,45]])
        url_string = NSURL.URLWithString(user['fb_profile_image_square_url'])
        profile_image_view.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("friends.png"))

        containerView.addSubview profile_image_view

        layer = profile_image_view.layer
        layer.cornerRadius = 3
        layer.masksToBounds = true

        # profile_button = UIButton.buttonWithType(UIButtonTypeCustom)
        # profile_button.frame = [[4,4],[45,45]]
        # profile_button.addTarget(self, action:"didTapUserButtonAction", forControlEvents:UIControlEventTouchUpInside)
        # containerView.addSubview profile_button

        tagged_label = UILabel.alloc.initWithFrame [[55, 3], [180, 30]]
        tagged_label.font = @font_light
        tagged_label.backgroundColor = UIColor.clearColor
        tagged_label.text = user['name']

        containerView.addSubview tagged_label

        tagged << containerView
      end

      tagged.each do |view|
        @scrollView.addSubview view
      end
    end

    @scrollView.addSubview(photoImageView)
    size = self.pro_photo ? [320, 300 + tagged.size * 54] : [320, 400]
    @scrollView.setContentSize(size)
  end

  def viewWillAppear(animated)
    setToolbarButtons
  end

  def setToolbarButtons
    buttons = []

    flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

    more_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemTrash, target:self, action:'showOptions')

    buttons << flexibleSpace
    buttons << App.delegate.points
    buttons << flexibleSpace
    buttons << more_button if photo['user_id'] == App.delegate.current_user.id

    App.delegate.navToolbar.setItems(buttons, animated:false)
  end

  def showOptions
    popupQuery = UIActionSheet.alloc.initWithTitle("", delegate:self, cancelButtonTitle:'Cancel', destructiveButtonTitle:"Delete", otherButtonTitles:nil)
    popupQuery.delegate = self
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent
    popupQuery.showInView(view)
  end

  def actionSheet(actionSheet, clickedButtonAtIndex:buttonIndex)
    puts buttonIndex
    case buttonIndex
      when 0
        deletePhoto
      when 1
        # cancelled
    end
  end

  def deletePhoto
    App.delegate.notificationController.setNotificationTitle "Deleting photo"
    App.delegate.notificationController.show
    fan_photo = Frequency::FanPhoto.new(photo['id'])
    fan_photo.destroy #{|request| puts request}
    App.run_after(1) { App.delegate.user_photos_list.refresh; self.navigationController.popViewControllerAnimated(true) }
  end

end