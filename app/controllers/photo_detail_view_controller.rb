class PhotoDetailViewController < UIViewController

  def loadView
    # self.view = UIImageView.alloc.init
    view.delegate = self
    view.indicatorStyle = UIScrollViewIndicatorStyleWhite
  end

  def viewDidLoad

  end

  def viewDidAppear(animated)
    # @my_image_view = UIImageView.alloc.initWithImage(@photo)
    # view.contentSize = @my_image_view.bounds.size
  end

end