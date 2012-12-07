class FriendsGridController < KKGridViewController

  def loadView
    super
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(App.delegate.navToolbar)

    gridView.scrollsToTop = true
    gridView.backgroundColor = UIColor.blackColor
    gridView.cellSize = [160,160]
    gridView.cellPadding = [0,0]
    # self.view = UIView.alloc.init
    # self.gridView = gridView

    backgroundView = UIView.alloc.init
    backgroundView.backgroundColor = UIColor.blackColor #UIColor.scrollViewTexturedBackgroundColor
    self.gridView.backgroundView = backgroundView
    self.gridView.reloadData
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(App.delegate.navToolbar)
  end

  def viewDidLoad
    super
    @friends = App.delegate.friends.all
  end

  def viewDidUnload
    super
  end

  def viewWillAppear(animated)
    App.delegate.setToolbarButtonsForOther
    App.delegate.friends.refresh
  end

  def friendsDidLoad
    @friends = App.delegate.friends.all
    # TODO: FIX THIS - self.gridView.reloadData
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
    image_view.setContentMode(UIViewContentModeScaleAspectFill)

    layer = image_view.layer
    layer.masksToBounds = true

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
    gridView.deselectAll true
    friend = @friends[indexPath.index]
    detail_view_controller = App.delegate.friendDetailViewController
    detail_view_controller.friend_id = friend['id']
    detail_view_controller.profile_image_url = friend['fb_profile_image_url']
    self.navigationController.pushViewController(detail_view_controller, animated:true)
  end

end
