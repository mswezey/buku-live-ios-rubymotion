class PhotoCell < UITableViewCell
  attr_accessor :photo

  def initWithStyle(style, reuseIdentifier:cell_identifier, photo:photo)
    self.photo = photo
    puts "init with style"
    if initWithStyle(style, reuseIdentifier:cell_identifier)
      puts "if init with style"
      self.contentView.backgroundColor = UIColor.clearColor
      self.opaque = false
      self.selectionStyle = UITableViewCellSelectionStyleNone
      self.accessoryType = UITableViewCellAccessoryNone
      self.clipsToBounds = true

      @dropshadowView = UIView.alloc.init
      @dropshadowView.backgroundColor = UIColor.whiteColor
      @dropshadowView.frame = CGRectMake( 10, -44.0, 300, 300)
      self.contentView.addSubview @dropshadowView

      layer = @dropshadowView.layer
      layer.masksToBounds = false
      layer.shadowRadius = 3.0
      layer.shadowOpacity = 0.5
      layer.shadowOffset = CGSizeMake(0.0, 1.0)
      layer.shouldRasterize = true

      self.imageView.frame = CGRectMake(10, 0.0, 300.0, 300.0)
      self.imageView.backgroundColor = UIColor.blackColor
      self.imageView.contentMode = UIViewContentModeScaleAspectFill
      layer = self.imageView.layer
      layer.masksToBounds = true

      @photoButton = UIButton.buttonWithType(UIButtonTypeCustom)
      @photoButton.frame = CGRectMake( 10, 0.0, 300.0, 300.0)
      @photoButton.backgroundColor = UIColor.clearColor
      @photoButton.addTarget(self, action:"showPhoto", forControlEvents:UIControlEventTouchUpInside)
      contentView.addSubview(@photoButton)

      self.contentView.bringSubviewToFront self.imageView
      self.contentView.bringSubviewToFront @photoButton

      unless self.photo['taken_by']
        puts "pro photo"
        self.imageView.frame = CGRectMake(5, 0, 310, 213)
        self.contentView.frame = CGRectMake(5, 0, 310, 213)
        @dropshadowView.frame = CGRectMake(5, -44.0, 310, 213)
        @photoButton.frame = CGRectMake(5, 0, 310, 213)
      else
        puts "fan photo"
      end
    end
    self
  end

  def showPhoto
    viewController = EditPhotoViewController.alloc.initWithImage(self.imageView.image, photo:self.photo)
    App.delegate.gridNavController.pushViewController(viewController, animated:true)
  end

  def layoutSubviews
    super
    unless self.photo['taken_by']
      puts "layoutSubviews pro photo"
      self.imageView.frame = CGRectMake(5, 0, 310, 213)
      self.contentView.frame = CGRectMake(0, 0, 310, 213)
      @dropshadowView.frame = CGRectMake(5, -44.0, 310, 213)
      @photoButton.frame = CGRectMake(5, 0, 310, 213)
    else
      puts "layoutSubviews fan photo"
      self.imageView.frame = CGRectMake(10, 0, 300, 300)
      self.contentView.frame = CGRectMake(0, 0, 300, 300)
      @photoButton.frame = CGRectMake(10, 0, 300, 300)
      @dropshadowView.frame = CGRectMake(10, -44.0, 300, 300)
    end
  end
end