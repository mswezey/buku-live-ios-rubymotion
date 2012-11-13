class MapController < UIViewController
  def didReceiveMemoryWarning
    super
  end

  def initWithTabBar
    me = init
    anImage = UIImage.imageNamed("map.png")
    me.tabBarItem = UITabBarItem.alloc.initWithTitle("Map", image:anImage, tag:1)
    me
  end

  def loadView
    views = NSBundle.mainBundle.loadNibNamed("MapView", owner:self, options:nil)
    self.view = views[0]
  end

  def viewDidLoad
    view.backgroundColor = UIColor.lightGrayColor

    @my_map_view = MKMapView.alloc.initWithFrame([[0,0], [320,300]])
    @my_map_view.mapType = MKMapTypeSatellite
    location = CLLocationCoordinate2DMake(32.78145, -96.76372)
    region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.001, 0.001))

    @my_map_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight

    view.addSubview(@my_map_view)

    @my_map_view.setRegion(region)

    # view.backgroundColor = UIColor.blackColor
    @scroll_view = view.viewWithTag(1)
    @scroll_view.delegate = self
  end

  def viewDidAppear(animated)
    @scroll_view.indicatorStyle = UIScrollViewIndicatorStyleWhite
    map = UIImage.imageNamed("MapBig.jpg")
    @my_image_view = UIImageView.alloc.initWithImage(map)
    @scroll_view.contentSize = @my_image_view.bounds.size
    @scroll_view.addSubview(@my_image_view)
  end

  # def scrollViewDidScroll(scrollView)
  #   @scroll_view.alpha = 0.5
  # end

  # def scrollViewDidEndDecelerating(scrollView)
  #   @scroll_view.alpha = 1.0
  # end

  # def scrollViewDidEndDragging(scrollView)
  #   @scroll_view.alpha = 1.0
  # end

end