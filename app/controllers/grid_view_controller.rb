class GridViewController < UIViewController

  def viewDidLoad
    @scroll_view = UIScrollView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @scroll_view.delegate = self
  end

  def viewDidAppear(animated)
    @photos = UIView.alloc.initWithFrame([[0,0],[320, 160]])
    @photos.backgroundColor = UIColor.blueColor

    @now_playing = UIView.alloc.initWithFrame([[0,160],[160, 160]])
    @now_playing.backgroundColor = UIColor.greenColor

    @still_to_come = UIView.alloc.initWithFrame([[160, 160],[160, 160]])
    @still_to_come.backgroundColor = UIColor.redColor

    @my_points = UIView.alloc.initWithFrame([[0, 320],[160, 160]])
    @my_points.backgroundColor = UIColor.lightGrayColor

    @badges = UIView.alloc.initWithFrame([[160, 320],[160, 160]])
    @badges.backgroundColor = UIColor.blueColor

    @friends = UIView.alloc.initWithFrame([[0, 480],[160, 160]])
    @friends.backgroundColor = UIColor.greenColor

    @activity = UIView.alloc.initWithFrame([[160, 480],[160, 160]])
    @activity.backgroundColor = UIColor.redColor

    @scroll_view.contentSize = [320, 640]

    view.addSubview(@scroll_view)
    @scroll_view.addSubview(@photos)
    @scroll_view.addSubview(@now_playing)
    @scroll_view.addSubview(@still_to_come)
    @scroll_view.addSubview(@my_points)
    @scroll_view.addSubview(@badges)
    @scroll_view.addSubview(@friends)
    @scroll_view.addSubview(@activity)
  end
end