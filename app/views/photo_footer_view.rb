class PhotoFooterView < UIView
  attr_accessor :photo, :containerView

  COMMENT_VIEW_HEIGHT = 25

  def initWithFrame(frame, photo:photo)
    @photo = photo
    if super.initWithFrame(frame)
      self.containerView = UIView.alloc.init
      self.containerView.setBackgroundColor UIColor.darkGrayColor
      self.addSubview containerView
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