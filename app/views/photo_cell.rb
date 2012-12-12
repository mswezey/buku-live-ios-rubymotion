class PhotoCell < UITableViewCell
  attr_accessor :photo, :comments_view

  def initWithStyle(style, reuseIdentifier:cell_identifier, photo:photo)
    self.photo = photo

    if initWithStyle(style, reuseIdentifier:cell_identifier)

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

      if photo['comments'] && photo['comments'].size > 0
        self.comments_view = CommentsView.alloc.initWithComments(photo['comments'])
        contentView.addSubview comments_view
      end

      unless self.photo['taken_by']
        puts "pro photo"
        self.imageView.frame = CGRectMake(5, 0, 310, 213)
        self.contentView.frame = CGRectMake(5, 0, 310, 213)
        @dropshadowView.frame = CGRectMake(5, -44.0, 310, 213)
        @photoButton.frame = CGRectMake(5, 0, 310, 213)
      else
        puts "fan photo"
      end

      if comments_view
        frame = comments_view.frame
        frame = [[frame.origin.x, frame.origin.y + frame.size.height + 5],[75,23]]
      else
        frame = imageView.frame
        frame = [[frame.origin.x, frame.origin.y + frame.size.height + 5],[75,23]]
      end
      comment_button = UIButton.buttonWithType(UIButtonTypeCustom)
      comment_button.frame = frame
      comment_button.addTarget(self, action:"showPhoto", forControlEvents:UIControlEventTouchUpInside)
      comment_button.setTitle("Comment", forState: UIControlStateNormal)
      comment_button.backgroundColor = UIColor.darkGrayColor
      comment_button.font = UIFont.fontWithName("DIN-Light", size:14)
      comment_button.titleLabel.textColor = UIColor.whiteColor
      cb_layer = comment_button.layer
      cb_layer.setBorderWidth 1
      cb_layer.setBorderColor UIColor.lightGrayColor.CGColor
      cb_layer.cornerRadius = 3
      contentView.addSubview comment_button
      self.contentView.bringSubviewToFront comment_button
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
      self.imageView.frame = CGRectMake(0, 0, 310, 213)
      self.contentView.frame = CGRectMake(5, 0, 310, 213)
      @dropshadowView.frame = CGRectMake(0, -44.0, 310, 213)
      @photoButton.frame = CGRectMake(0, 0, 310, 213)
    else
      self.imageView.frame = CGRectMake(0, 0, 300, 300)
      self.contentView.frame = CGRectMake(10, 0, 300, comments_view ? comments_view.frame.size.height + 335 : 335)
      @photoButton.frame = CGRectMake(0, 0, 300, 300)
      @dropshadowView.frame = CGRectMake(0, -44.0, 300, 300)
    end
  end
end