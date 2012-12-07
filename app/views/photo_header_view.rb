class PhotoHeaderView < UIView
  attr_accessor :photo

  def initWithFrame(frame, photo:photo)
    @photo = photo
    if super.initWithFrame(frame)
      self.backgroundColor = UIColor.grayColor

      containerView = UIView.alloc.initWithFrame([[10, 20],[self.bounds.size.width - 10 * 2, 54]])
      self.addSubview containerView
      containerView.setBackgroundColor UIColor.whiteColor

      profile_image_view = UIImageView.alloc.initWithFrame([[4,4],[45,45]])
      url_string = NSURL.URLWithString(@photo['taken_by_thumbnail_url'])
      profile_image_view.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("friends.png"))

      containerView.addSubview profile_image_view

      layer = profile_image_view.layer
      layer.cornerRadius = 3
      layer.masksToBounds = true

      profile_button = UIButton.buttonWithType(UIButtonTypeCustom)
      profile_button.frame = [[4,4],[45,45]]
      profile_button.addTarget(self, action:"didTapUserButtonAction", forControlEvents:UIControlEventTouchUpInside)
      containerView.addSubview profile_button



      taken_by_label = UILabel.alloc.initWithFrame [[55, 0], [180, 30]]
      taken_by_label.font = UIFont.boldSystemFontOfSize(15)
      taken_by_label.backgroundColor = UIColor.clearColor
      taken_by_label.text = @photo['taken_by']

      containerView.addSubview taken_by_label

      taken_at_label = UILabel.alloc.initWithFrame [[55, 20], [180, 20]]
      taken_at_label.font = UIFont.systemFontOfSize(12)
      taken_at_label.textColor = UIColor.grayColor
      taken_at_label.backgroundColor = UIColor.clearColor
      taken_at_label.text = @photo['taken_at_in_words']

      containerView.addSubview taken_at_label

    end
    self
  end

  def didTapUserButtonAction
    detail_view_controller = App.delegate.friendDetailViewController
    detail_view_controller.friend_id = @photo['user_id']
    detail_view_controller.profile_image_url = @photo['taken_by_thumbnail_url']
    App.delegate.gridNavController.pushViewController(detail_view_controller, animated:true)
  end

end