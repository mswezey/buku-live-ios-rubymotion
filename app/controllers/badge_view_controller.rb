class BadgeViewController < UIViewController
  attr_accessor :carousel, :badges

  def init
    if super
      self.badges = []
    end
    self
  end

  def numberOfItemsInCarousel(carousel)
    badges.size
  end

  def carousel(carousel, viewForItemAtIndex:index, reusingView:view)
    badge = badges[index]
    if view == nil

      view = UIImageView.alloc.initWithFrame([[0,0],[160,160]])
      view.contentMode = UIViewContentModeCenter

      label = UILabel.alloc.initWithFrame([[0,140],[160,16]])
      label.backgroundColor = UIColor.clearColor
      label.textAlignment = UITextAlignmentCenter
      label.font = UIFont.fontWithName("DIN-Medium", size:14)
      label.textColor = UIColor.whiteColor
      label.tag = 1
      view.addSubview(label)
    else
      label = view.viewWithTag(1)
    end
    if badge["badge_preloaded"]
      view.image = UIImage.imageNamed(badge["badge_image_filename"])
    else
      view.setImageWithURL(NSURL.URLWithString(badge['badge_image_url']), placeholder: UIImage.imageNamed("friends.png")) # TODO: Make badge placeholder image
    end
    label.text = badge["name"]
    view
  end

  def carousel(carousel, valueForOption:option, withDefault:value)
    case option

    when 10 #iCarouselOptionFadeMin
      return -0.2;
    when 11 #iCarouselOptionFadeMax
      return 0.2;
    when 12 # iCarouselOptionFadeRange:
      return 2.0;
    else
      return value;
    end

  end


end