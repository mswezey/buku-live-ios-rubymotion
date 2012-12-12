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
      @tagged = []

      containerView = UIView.alloc.initWithFrame([[5,245 + @tagged.size * 54], [310, 54]])
      containerView.backgroundColor = UIColor.whiteColor
      tagged_label = UILabel.alloc.initWithFrame [[13, 10], [180, 30]]
      tagged_label.font = UIFont.fontWithName("DIN-Light", size:24)
      tagged_label.backgroundColor = UIColor.clearColor
      tagged_label.text = "In this photo"
      containerView.addSubview tagged_label

      @tagged << containerView

      photo['users'].each do |user|
        containerView = UIView.alloc.initWithFrame([[5,245 + @tagged.size * 54], [310, 54]])
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

        @tagged << containerView
      end

      @tagged.each do |view|
        @scrollView.addSubview view
      end
    end

    @scrollView.addSubview(@photoImageView)

    if photo['comments']
      add_comments(photo['comments'])
    end

    size = self.pro_photo ? [320, 300 + @tagged.size * 54] : [320, 400]
    size[1] = @comments_view ? size[1] + @comments_view.size.height + 42 : size[1]
    @scrollView.setContentSize(size)
  end

  def add_comments(comments)
    @comments_view.removeFromSuperview if @comments_view
    @commentField.removeFromSuperview if @commentField

    @comments_view = CommentsView.alloc.initWithComments(comments)
    @comments_view.frame = [[10, @photoImageView.frame.origin.y + @photoImageView.frame.size.height + 5], [@comments_view.frame.size.width, @comments_view.frame.size.height]]
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

    size = self.pro_photo ? [320, 300 + @tagged.size * 54] : [320, 400]
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
      return false
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

end