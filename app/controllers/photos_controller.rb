class PhotosController < UITableViewController

  def didReceiveMemoryWarning
    super
  end

  def initWithTabBar
    me = init
    anImage = UIImage.imageNamed("photos.png")
    me.tabBarItem = UITabBarItem.alloc.initWithTitle("Photos", image:anImage, tag:1)
    me
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    225
  end

  def setToolbarButtons
    buttons = []

    flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)
    camera_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCamera, target:self, action:'photoCaptureButtonAction')

    buttons << flexibleSpace
    buttons << App.delegate.points
    buttons << camera_button

    App.delegate.navToolbar.setItems(buttons, animated:false)
  end

  def photoCaptureButtonAction
    cameraDeviceAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
    photoLibraryAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypePhotoLibrary)
    if cameraDeviceAvailable && photoLibraryAvailable
      popupQuery = UIActionSheet.alloc.initWithTitle("", delegate:self, cancelButtonTitle:'Cancel', destructiveButtonTitle:nil, otherButtonTitles:"Take Picture", "Choose Existing", nil)
      popupQuery.delegate = self
      popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque
      popupQuery.showInView(view)
    else
      shouldStartPhotoLibraryPickerController
    end
  end

  def shouldStartCameraController
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera) == false
      return false
    end

    cameraUI = UIImagePickerController.alloc.init

    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera) && UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceTypeCamera).containsObject(KUTTypeImage)

      cameraUI.mediaTypes = [KUTTypeImage]
      cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera

      if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDeviceRear)
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear
      elsif UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDeviceFront)
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront
      end

    else
      return false
    end

    cameraUI.allowsEditing = true
    cameraUI.showsCameraControls = true
    cameraUI.delegate = self

    self.presentModalViewController(cameraUI, animated:true)

    return true
  end

  def shouldStartPhotoLibraryPickerController
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypePhotoLibrary) == false && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeSavedPhotosAlbum) == false
      return false
    end

    cameraUI = UIImagePickerController.alloc.init
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypePhotoLibrary) && UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceTypePhotoLibrary).containsObject(KUTTypeImage)

        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary
        cameraUI.mediaTypes = [KUTTypeImage]

    elsif UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeSavedPhotosAlbum) && UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceTypeSavedPhotosAlbum).containsObject(KUTTypeImage)
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum
        cameraUI.mediaTypes = [KUTTypeImage]
    else
      return false
    end

    cameraUI.allowsEditing = true
    cameraUI.delegate = self

    self.presentModalViewController(cameraUI, animated:true)

    return true
  end

  def shouldPresentPhotoCaptureController
    presentedPhotoCaptureController = shouldStartCameraController

    if !presentedPhotoCaptureController
      presentedPhotoCaptureController = shouldStartPhotoLibraryPickerController
    end

    return presentedPhotoCaptureController
  end

  def actionSheet(actionSheet, clickedButtonAtIndex:buttonIndex)
    case buttonIndex
      when 0
        shouldStartCameraController
      when 1
        shouldStartPhotoLibraryPickerController # choose_existing
      when 2
        # cancelled
    end
  end


  def viewDidLoad
    super
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(App.delegate.navToolbar)
    view.dataSource = view.delegate = self
  end

  def objectLoader(object_loader, didLoadObjects:coffee_shops)
    add_coffee_shops(coffee_shops)
  end

  def objectLoader(object_loader, didFailWithError:error)
    log "Error: #{error.inspect}"
  end

  def viewWillAppear(animated)
    setToolbarButtons
    App.delegate.user_photos_list.refresh
    load_photos
  end

  def viewDidAppear(animated)
    self.view.alpha = 1.0
  end

  def viewDidUnload
    super
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation == UIInterfaceOrientationPortrait
  end

## Table view data source

  def numberOfSectionsInTableView(tableView)
    # Return the number of sections.
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    # Return the number of rows in the section.
    @photos ? @photos.length : 0
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
      # cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      cell
    end
    photo = @photos[indexPath.row]

    string = photo['fan_photo']['image']['mobile_small']['url']
    urlString = NSURL.URLWithString(string)

    # cell.imageView.setImageWithURL(urlString, placeholderImage: UIImage.imageNamed("photo-placeholder.png"))

    image_view = UIImageView.alloc.init
    image_view.setImageWithURL(urlString, placeholderImage: UIImage.imageNamed("photo-placeholder.png"))
    image_view.setContentMode(UIViewContentModeScaleAspectFill)

    layer = image_view.layer
    layer.masksToBounds = true

    cell.backgroundView = image_view
    # [ [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"cell_normal.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ]autorelease];

    cell
  end

=begin
  # Override to support conditional editing of the table view.
  def tableView(tableView, canEditRowAtIndexPath:indexPath)
    # Return false if you do not want the specified item to be editable.
    true
  end
=end

=begin
  # Override to support editing the table view.
  def tableView(tableView, commitEditingStyle:editingStyle forRowAtIndexPath:indexPath)
    if editingStyle == UITableViewCellEditingStyleDelete
      # Delete the row from the data source
      tableView.deleteRowsAtIndexPaths(indexPath, withRowAnimation:UITableViewRowAnimationFade)
    elsif editingStyle == UITableViewCellEditingStyleInsert
      # Create a new instance of the appropriate class, insert it into the
      # array, and add a new row to the table view
    end
  end
=end

=begin
  # Override to support rearranging the table view.
  def tableView(tableView, moveRowAtIndexPath:fromIndexPath, toIndexPath:toIndexPath)
  end
=end

=begin
  # Override to support conditional rearranging of the table view.
  def tableView(tableView, canMoveRowAtIndexPath:indexPath)
    # Return false if you do not want the item to be re-orderable.
    true
  end
=end

## Table view delegate

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    # Navigation logic may go here. Create and push another view controller.
    detailViewController = PhotoDetailViewController.alloc.init
    detailViewController.view = UIScrollView.alloc.initWithFrame(self.view.bounds)

    photo = @photos[indexPath.row]
    url = NSURL.URLWithString(photo['fan_photo']['image']['mobile_medium']['url'])
    data = NSData.dataWithContentsOfURL(url)
    image = UIImage.imageWithData(data)
    image_view = UIImageView.alloc.initWithImage(image)
    detailViewController.view.contentSize = image_view.bounds.size
    detailViewController.view.addSubview(image_view)

    # Pass the selected object to the new view controller.
    self.navigationController.pushViewController(detailViewController, animated:true)
  end

  def resizeImage(image, width, height)
    size = image.size # TODO: make new size object correct way
    size.width = width
    size.height = height
    newRect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height))
    imageRef = image.CGImage
    UIGraphicsBeginImageContext(size)
    context = UIGraphicsGetCurrentContext()

    CGContextSetInterpolationQuality(context, KCGInterpolationHigh)
    flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, size.height)

    CGContextConcatCTM(context, flipVertical)
    CGContextDrawImage(context, newRect, imageRef)

    newImageRef = CGBitmapContextCreateImage(context)
    newImage = UIImage.imageWithCGImage(newImageRef)

    CGImageRelease(newImageRef)
    UIGraphicsEndImageContext()

    return newImage
  end

  def takePhoto
    return false
    BW::Device.camera.rear.picture(media_types: [:image]) do |result|
      image = result[:original_image]
      # small_image = UIImage.imageWithCGImage(image.CGImage, scale:0.5, orientation:image.imageOrientation)
      # image_view = UIImageView.alloc.initWithImage(image)

      # image_data = NSData.initWithImage(image)
      # image_png = UIImagePNGRepresentation(image)

      small_image = resizeImage(image, 960, 716)
      image_jpeg = UIImageJPEGRepresentation(small_image, 0.2)

      # self.title = "Uploading image..."
      # self.view.image = small_image
      self.view.alpha = 0.5

      # progressBlock = Proc.new do |sending, written, expected|
        # while sending <= expected do
        #   @label.text = "#{sending} #{written} #{expected}"
        #   sleep 1
        # end
      # end
      # , :upload_progress => progressBlock
      data = {auth_token: App::Persistence['user_auth_token']}
      BW::HTTP.post("#{App.delegate.frequency_app_uri}/api/mobile/fan_photos", {payload: data, files: {:picture => image_jpeg} }) do |response|
        if response.ok?
          self.view.alpha = 1.0
          App.delegate.user_photos_list.refresh {load_photos}
        else
          # TODO: handle failure
        end
      end
    end
  end

  def load_photos
    @photos = App.delegate.user_photos_list.all
    self.view.reloadData
  end

  def imagePickerControllerDidCancel(picker)
    self.dismissModalViewControllerAnimated(true)
  end

  def imagePickerController(picker, didFinishPickingMediaWithInfo:info)
    self.dismissModalViewControllerAnimated(false)

    image = info.objectForKey(UIImagePickerControllerEditedImage)

    viewController = EditPhotoViewController.alloc.initWithImage(image)
    viewController.setModalTransitionStyle(UIModalTransitionStyleCrossDissolve)

    navController = UINavigationController.alloc.initWithRootViewController(viewController)

    navController.setModalTransitionStyle(UIModalTransitionStyleCrossDissolve)
    navController.navigationBar.setBackgroundImage(UIImage.imageNamed("top-nav-bg.png"), forBarMetrics: UIBarMetricsDefault)

    self.presentModalViewController(navController, animated:true)
  end

end