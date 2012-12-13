class EditPhotoViewController < UIViewController
  attr_accessor :image, :photo, :pro_photo, :users

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

    if photo['users']
      self.users = photo['users']
    else
      self.users = []
    end

    me
  end

  def viewDidLoad
    super

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(App.delegate.navToolbar)

    NSNotificationCenter.defaultCenter.addObserver(self, selector:"keyboardWillShow:", name:UIKeyboardWillShowNotification, object:nil)

    NSNotificationCenter.defaultCenter.addObserver(self, selector:"keyboardWillHide:", name:UIKeyboardWillHideNotification, object:nil)

    @scrollView = UIScrollView.alloc.initWithFrame(view.bounds)
    @scrollView.delegate = self
    @scrollView.backgroundColor = UIColor.darkGrayColor
    self.view.addSubview @scrollView

    frame = self.pro_photo ? [[5, 32], [310, 213]] : [[10, 22], [300, 300]]

    @photoImageView = UIImageView.alloc.initWithFrame(frame)
    @photoImageView.setBackgroundColor(UIColor.blackColor)
    @photoImageView.setImage(self.image)
    @photoImageView.setContentMode(UIViewContentModeScaleAspectFill)

    layer = @photoImageView.layer
    layer.masksToBounds = true
    layer.shadowRadius = 3.0
    layer.shadowOffset = [0.0, 2.0]
    layer.shadowOpacity = 0.5
    layer.shouldRasterize = true

    if self.pro_photo && photo['users'].size > 0
      # @tagged = []

      i_carousel = NSClassFromString('iCarousel')
      @tagged_users_view = i_carousel.alloc.initWithFrame([[5,235], [310, 140]])
      @tagged_users_view.layer.cornerRadius = 4
      @tagged_users_view.backgroundColor = '#133948'.to_color
      @tagged_users_view.type = 8
      @tagged_users_view.delegate = self
      @tagged_users_view.dataSource = self
      @tagged_users_view.clipsToBounds = true

      tagged_label = UILabel.alloc.initWithFrame [[5, 10], [310, 30]]
      tagged_label.font = UIFont.fontWithName("DIN-Light", size:18)
      tagged_label.backgroundColor = UIColor.clearColor
      tagged_label.textColor = UIColor.whiteColor
      tagged_label.text = "In this photo"
      @tagged_users_view.addSubview tagged_label

      # @tagged_users_view = UIView.alloc.initWithFrame([[5,245], [310, 54]])

      # tagged_user_view = UIView.alloc.initWithFrame([[0,0], [310, 54]])
      # tagged_user_view.backgroundColor = UIColor.whiteColor
      # tagged_label = UILabel.alloc.initWithFrame [[13, 10], [180, 30]]
      # tagged_label.font = UIFont.fontWithName("DIN-Light", size:24)
      # tagged_label.backgroundColor = UIColor.clearColor
      # tagged_label.text = "In this photo"
      # tagged_user_view.addSubview tagged_label

      # @tagged_users_view.addSubview tagged_user_view

      # users.each_with_index do |user, i|
      #   tagged_user_view = UIView.alloc.initWithFrame([[0, i * 54 + 54], [310, 54]])
      #   tagged_user_view.backgroundColor = UIColor.whiteColor
      #   profile_image_view = UIImageView.alloc.initWithFrame([[4,4],[45,45]])
      #   url_string = NSURL.URLWithString(user['fb_profile_image_square_url'])
      #   profile_image_view.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("friends.png"))

      #   tagged_user_view.addSubview profile_image_view

      #   layer = profile_image_view.layer
      #   layer.cornerRadius = 3
      #   layer.masksToBounds = true

      #   # profile_button = UIButton.buttonWithType(UIButtonTypeCustom)
      #   # profile_button.frame = [[4,4],[45,45]]
      #   # profile_button.addTarget(self, action:"didTapUserButtonAction", forControlEvents:UIControlEventTouchUpInside)
      #   # tagged_user_view.addSubview profile_button

      #   tagged_label = UILabel.alloc.initWithFrame [[55, 3], [180, 30]]
      #   tagged_label.font = @font_light
      #   tagged_label.backgroundColor = UIColor.clearColor
      #   tagged_label.text = user['name']

      #   tagged_user_view.addSubview tagged_label

      #   @tagged_users_view.addSubview tagged_user_view
      # end

      # @tagged.each do |view|
      #   @scrollView.addSubview view
      # end
      @scrollView.addSubview @tagged_users_view

      # UIView.animateWithDuration(2, animations:lambda do
      #   @tagged_users_view.frame = [[@tagged_users_view.frame.origin.x,@tagged_users_view.frame.origin.y],[@tagged_users_view.frame.size.width, 54 + users.size * 54]]
      # end)
    end

    @scrollView.addSubview(@photoImageView)

    if photo['comments']
      add_comments(photo['comments'])
    end

    if self.pro_photo
      size = @tagged_users_view ? [320, 100 + @tagged_users_view.frame.origin.y + @tagged_users_view.frame.size.height] : [320, 400]
    else
      size = [320, 400]
    end
    size[1] = @comments_view ? size[1] + @comments_view.size.height + 52 : size[1]
    @scrollView.setContentSize(size)
  end

  def add_comments(comments)
    @comments_view.removeFromSuperview if @comments_view
    @commentField.removeFromSuperview if @commentField

    @comments_view = CommentsView.alloc.initWithComments(comments)

    if @tagged_users_view
      @comments_view.frame = [[10, @tagged_users_view.frame.origin.y + @tagged_users_view.frame.size.height + 5], [@comments_view.frame.size.width, @comments_view.frame.size.height]]
    else
      @comments_view.frame = [[10, @photoImageView.frame.origin.y + @photoImageView.frame.size.height + 5], [@comments_view.frame.size.width, @comments_view.frame.size.height]]
    end


    @scrollView.addSubview @comments_view

    @commentField = UITextField.alloc.initWithFrame([[10, @comments_view.frame.origin.y + @comments_view.frame.size.height],[@comments_view.frame.size.width, 31]])
    @commentField.font = UIFont.fontWithName("DIN-Medium", size:14)
    @commentField.placeholder = "Add a comment"
    @commentField.returnKeyType = UIReturnKeySend
    @commentField.textColor = UIColor.darkGrayColor
    @commentField.backgroundColor = UIColor.whiteColor
    @commentField.setBorderStyle UITextBorderStyleRoundedRect
    @commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter
    @commentField.delegate = self
    @scrollView.addSubview @commentField

    if self.pro_photo
      size = @tagged_users_view ? [320, 100 + @tagged_users_view.frame.origin.y + @tagged_users_view.frame.size.height] : [320, 400]
    else
      size = [320, 400]
    end
    size[1] = @comments_view ? size[1] + @comments_view.size.height + 42 : size[1]
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
    fan_photo.destroy
    App.run_after(1) { App.delegate.user_photos_list.refresh; self.navigationController.popViewControllerAnimated(true) }
  end

  def keyboardWillShow(note)
    keyboardFrameEnd = note.userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey).CGRectValue
    scrollViewContentSize = @scrollView.contentSize
    scrollViewContentSize.height += keyboardFrameEnd.size.height
    @scrollView.setContentSize scrollViewContentSize

    scrollViewContentOffset = @scrollView.contentOffset
    scrollViewContentOffset.y += keyboardFrameEnd.size.height
    scrollViewContentOffset.y -= 42
    @scrollView.setContentOffset(scrollViewContentOffset, animated:true)
  end

  def keyboardWillHide(note)
    keyboardFrameEnd = note.userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey).CGRectValue
    scrollViewContentSize = @scrollView.contentSize
    scrollViewContentSize.height -= keyboardFrameEnd.size.height

    UIView.animateWithDuration(0.2, animations:lambda {
      @scrollView.setContentSize scrollViewContentSize
    })
  end

  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
    postComment(textField.text)
    textField.text = ""
  end

  def scrollViewWillBeginDragging(scrollView)
    @commentField.resignFirstResponder
  end

  def postComment(text)
    if pro_photo
      pro_photo = Frequency::ProPhoto.new(photo['id'])
      path = "#{pro_photo.path}/comments"
      params = pro_photo.params.merge(comment:text)
      App.delegate.notificationController.setNotificationTitle "Posting comment"
      App.delegate.notificationController.show
      FRequest.new(POST, path, params, self)
    else
      fan_photo = Frequency::FanPhoto.new(photo['id'])
      path = "#{fan_photo.path}/comments"
      params = fan_photo.params.merge(comment:text)
      App.delegate.notificationController.setNotificationTitle "Posting comment"
      App.delegate.notificationController.show
      FRequest.new(POST, path, params, self)
    end
  end

  def request(request, didLoadResponse: response)
    App.delegate.notificationController.hide
    if response.isOK
      data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
      error_ptr = Pointer.new(:object)
      json = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      photo = json['fan_photo'] ? json['fan_photo'] : json['picture']
      add_comments(photo['comments'])
      App.delegate.combined_photos_list.refresh
    else
      App.alert("There was an error posting your comment.  Please try again later.")
    end
  end


  def numberOfItemsInCarousel(carousel)
    users.size
  end

  def carousel(carousel, viewForItemAtIndex:index, reusingView:view)
    user = users[index]
    if view == nil

      view = UIImageView.alloc.initWithFrame([[0,0],[120,60]])
      view.contentMode = UIViewContentModeCenter

      label = UILabel.alloc.initWithFrame([[0,70],[120,16]])
      label.backgroundColor = UIColor.clearColor
      label.textAlignment = UITextAlignmentCenter
      label.font = UIFont.fontWithName("DIN-Medium", size:14)
      label.textColor = UIColor.whiteColor
      label.tag = 1
      view.addSubview(label)
    else
      label = view.viewWithTag(1)
    end

    view.setImageWithURL(NSURL.URLWithString(user['fb_profile_image_square_url']), placeholder: UIImage.imageNamed("friends.png"))

    label.text = user["name"]
    view
  end

  # def carousel(carousel, valueForOption:option, withDefault:value)
  #   case option

  #   # when 10 #iCarouselOptionFadeMin
  #   #   return -0.2;
  #   # when 11 #iCarouselOptionFadeMax
  #   #   return 0.2;
  #   # when 12 # iCarouselOptionFadeRange:
  #   #   return 2.0;
  #   else
  #     return value;
  #   end

  # end

end