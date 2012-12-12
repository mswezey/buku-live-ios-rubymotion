class CommentsView < UIView
  attr_accessor :comments

  def initWithComments(comments)
    if init
      combined_label_height = 0
      comments.each_with_index do |comment, i|

        comment_profile_pic = UIImageView.alloc.initWithFrame([[0, combined_label_height], [20,20]])
        url_string = NSURL.URLWithString(comment['user']['fb_profile_image_square_url'])
        comment_profile_pic.setImageWithURL(url_string, placeholderImage: UIImage.imageNamed("friends.png"))
        self.addSubview comment_profile_pic

        comment_label = UILabel.alloc.initWithFrame [[30, combined_label_height], [260, 25]]
        comment_label.font = UIFont.fontWithName("DIN-Medium", size:12)
        comment_label.backgroundColor = UIColor.clearColor
        comment_label.textColor = UIColor.whiteColor
        comment_label.text = comment['comment']
        comment_label.numberOfLines = 0
        comment_label.sizeToFit
        self.addSubview comment_label

        comment_label_height = comment_label.frame.size.height < 22 ? 22 : comment_label.frame.size.height

        profile_button = UIButton.buttonWithType(UIButtonTypeCustom)
        profile_button.frame = [[0, combined_label_height],[300, comment_label_height]]
        profile_button.addTarget(self, action:"didTapUserButtonAction:", forControlEvents:UIControlEventTouchUpInside)
        profile_button.tag = comment['user']['id']
        self.addSubview profile_button

        # ensure min height of profile pic
        combined_label_height += comment_label_height + 10
      end
      self.frame = [[10, 305],[300, combined_label_height]]
    end
    self
  end

  def didTapUserButtonAction(sender)
    puts sender
    puts sender.tag
    detail_view_controller = App.delegate.friendDetailViewController
    detail_view_controller.friend_id = sender.tag
    detail_view_controller.profile_image_url = ""
    App.delegate.gridNavController.pushViewController(detail_view_controller, animated:true)
  end

end