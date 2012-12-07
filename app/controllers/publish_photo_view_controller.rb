class PublishPhotoViewController < UIViewController
  attr_accessor :image, :image_jpeg, :file_upload_background_task_id

  def initWithImage(aImage)
    me = init
    # @image = aImage
    self.image = aImage
    self.file_upload_background_task_id = UIBackgroundTaskInvalid
    me
  end

  def viewDidLoad
    super

    cancel_button = UIBarButtonItem.alloc.initWithTitle("Cancel", style:UIBarButtonItemStyleBordered, target:self, action:'dismissModal')
    self.navigationItem.leftBarButtonItem = cancel_button

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(App.delegate.navToolbar)

    @scrollView = UIScrollView.alloc.initWithFrame(view.bounds)
    @scrollView.delegate = self
    @scrollView.backgroundColor = UIColor.grayColor
    self.view.addSubview @scrollView

    photoImageView = UIImageView.alloc.initWithFrame([[20, 42], [280, 280]])
    photoImageView.setBackgroundColor(UIColor.blackColor)
    # photoImageView.setImage(@image)
    photoImageView.setImage(self.image)
    photoImageView.setContentMode(UIViewContentModeScaleAspectFit)

    layer = photoImageView.layer
    layer.masksToBounds = false
    layer.shadowRadius = 3.0
    layer.shadowOffset = [0.0, 2.0]
    layer.shadowOpacity = 0.5
    layer.shouldRasterize = true

    @scrollView.addSubview(photoImageView)

    @scrollView.setContentSize([320, 500])
  end

  def viewWillAppear(animated)
    setToolbarButtons
  end

  def setToolbarButtons
    buttons = []

    flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

    publish_button = UIBarButtonItem.alloc.initWithTitle("Publish", style:UIBarButtonItemStyleDone, target:self, action:'publishImage')

    buttons << flexibleSpace
    buttons << App.delegate.points
    buttons << flexibleSpace
    buttons << publish_button

    App.delegate.navToolbar.setItems(buttons, animated:false)
  end

  def dismissModal
    App.delegate.photosController.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(App.delegate.navToolbar)
    App.delegate.photosController.setToolbarButtons
    self.dismissModalViewControllerAnimated(true)
  end

  # def resizeImage(image, width, height)
  #   size = image.size # TODO: make new size object correct way
  #   size.width = width
  #   size.height = height
  #   newRect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height))
  #   imageRef = image.CGImage
  #   UIGraphicsBeginImageContext(size)
  #   context = UIGraphicsGetCurrentContext()

  #   CGContextSetInterpolationQuality(context, KCGInterpolationHigh)
  #   flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, size.height)

  #   CGContextConcatCTM(context, flipVertical)
  #   CGContextDrawImage(context, newRect, imageRef)

  #   newImageRef = CGBitmapContextCreateImage(context)
  #   newImage = UIImage.imageWithCGImage(newImageRef)

  #   CGImageRelease(newImageRef)
  #   UIGraphicsEndImageContext()

  #   return newImage
  # end

  def publishImage
    if self.file_upload_background_task_id != UIBackgroundTaskInvalid
      App.alert("Photo upload in progress.")
      return false
    end
    # small_image = resizeImage(@image, 960, 716)
    # imageData = UIImageJPEGRepresentation(small_image, 0.8)

    # image_jpeg = UIImageJPEGRepresentation(@image, 0.8)
    self.image_jpeg = UIImageJPEGRepresentation(image, 0.6)

    # self.file_upload_background_task_id = UIApplication.sharedApplication.beginBackgroundTaskWithExpirationHandler(lambda do
    #     puts "start background handler block"
    #     if self.file_upload_background_task_id != UIBackgroundTaskInvalid

    #       puts "#{self.file_upload_background_task_id}"
    #       # UIApplication.sharedApplication.endBackgroundTask(self.file_upload_background_task_id)
    #       # self.file_upload_background_task_id = UIBackgroundTaskInvalid
    #     end
    #     puts "end background handler block"
    # end)


    self.file_upload_background_task_id = UIApplication.sharedApplication.beginBackgroundTaskWithExpirationHandler(nil)

    puts "Requested background expiration task with id #{self.file_upload_background_task_id} for Fan Photo upload"
    data = {auth_token: App::Persistence['user_auth_token']}
    App.delegate.notificationController.setNotificationTitle "Uploading photo"
    App.delegate.notificationController.show

    BW::HTTP.post("#{App.delegate.frequency_app_uri}/api/mobile/fan_photos", {payload: data, files: {:picture => image_jpeg} }) do |response|
      if response.ok?
        puts "Fan Photo uploaded successfully"
        App.delegate.notificationController.hide
        App.delegate.user_photos_list.refresh
        UIApplication.sharedApplication.endBackgroundTask(self.file_upload_background_task_id)
      self.file_upload_background_task_id = UIBackgroundTaskInvalid
      dismissModal
      else
        App.delegate.notificationController.hide
        UIApplication.sharedApplication.endBackgroundTask(self.file_upload_background_task_id)
        self.file_upload_background_task_id = UIBackgroundTaskInvalid
        App.alert("There was an error uploading your photo.  Please try again later.")
        # TODO: handle failure
      end

    end

  end

end