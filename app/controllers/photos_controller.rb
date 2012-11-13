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

  def viewDidLoad
    super
    photos_string = File.read("#{App.documents_path}/fan_photos.json")
    @photos = BW::JSON.parse(photos_string)

    rightButton = UIBarButtonItem.alloc.initWithTitle("Take Photo", style: UIBarButtonItemStyleBordered, target:self, action:'takePhoto')
    self.navigationItem.rightBarButtonItem = rightButton
  end

  def viewDidAppear(animated)
    self.view.alpha = 1.0
    loadFanPhotos
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

    string = photo['fan_photo']['image']['my_picture']['url']
    urlString = NSURL.URLWithString(string)

    # cell.imageView.setImageWithURL(urlString, placeholderImage: UIImage.imageNamed("photo-placeholder.png"))

    image_view = UIImageView.alloc.init
    image_view.setImageWithURL(urlString, placeholderImage: UIImage.imageNamed("photo-placeholder.png"))
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
    url = NSURL.URLWithString(photo['fan_photo']['image']['medium']['url'])
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
    BW::Device.camera.rear.picture(media_types: [:movie, :image]) do |result|
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
          loadFanPhotos
        else
          # TODO: handle failure
        end
      end
    end
  end

  def loadFanPhotos
    data = {auth_token: App::Persistence['user_auth_token']}
    BW::HTTP.get("#{App.delegate.frequency_app_uri}/api/mobile/fan_photos", {payload: data}) do |response|
      if response.ok?
        json_string = response.body.to_str
        @photos = BW::JSON.parse(json_string).reverse
        # self.view.reloadData
        File.open("#{App.documents_path}/fan_photos.json", "w") {|f| f.write(json_string)}
      else
        # TODO: handle failure
      end
    end
  end

end