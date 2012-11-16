class FriendsGridController < KKGridViewController

  def loadView
    super
    gridView.scrollsToTop = true
    gridView.backgroundColor = UIColor.blueColor
    gridView.cellSize = [160,160]
    gridView.cellPadding = [0,0]
    # self.view = UIView.alloc.init
    # self.gridView = gridView

    self.title = "Friends"
    backgroundView = UIView.alloc.init
    backgroundView.backgroundColor = UIColor.blackColor #UIColor.scrollViewTexturedBackgroundColor
    self.gridView.backgroundView = backgroundView
    self.gridView.reloadData
  end

  def viewDidLoad
    super
    @friends = App.delegate.friends.all
  end

  def viewDidUnload
    super
  end

  def viewWillAppear(animated)
    self.navigationController.setNavigationBarHidden(false)
    App.delegate.friends.refresh do |complete|
      @friends = App.delegate.friends.all
      self.gridView.reloadData
    end
  end

  # def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
  #   interfaceOrientation == UIInterfaceOrientationPortrait
  # end

## Grid view data source

  def numberOfSectionsInGridView(gridView)
    # Return the number of sections.
    1
  end

  def gridView(gridView, numberOfItemsInSection:section)
    @friends ? @friends.length : 0
  end

  def gridView(gridView, cellForItemAtIndexPath:indexPath)
    friend = @friends[indexPath.index]
    url_string = NSURL.URLWithString(friend['fb_profile_image_url'])
    image_view = UIImageView.alloc.initWithFrame([[0,0],[160,160]])
    image_view.setImageWithURL(url_string, placeholder: UIImage.imageNamed("friends.png"))
    label = UILabel.alloc.initWithFrame([[0,130],[160,30]])
    label.textColor = UIColor.whiteColor
    label.backgroundColor = UIColor.blackColor.colorWithAlphaComponent(0.39)
    label.text = friend['name']

    cell = KKGridViewCell.cellForGridView(gridView)
    cell.contentView.addSubview(image_view)
    cell.contentView.addSubview(label)
    cell
  end

  def gridView(gridView, didSelectItemAtIndexPath:indexPath)
    friend = @friends[indexPath.index]
    detail_view_controller = FriendDetailViewController.alloc.init
    detail_view_controller.friend = friend
    self.navigationController.pushViewController(detail_view_controller, animated:true)
  end

end
