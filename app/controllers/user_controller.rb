class UserController < UIViewController

  def initWithTabBar
    me = init
    anImage = UIImage.imageNamed("profile.png")
    me.tabBarItem = UITabBarItem.alloc.initWithTitle("Profile", image:anImage, tag:1)
    me
  end

  def loadView
    # self.view = UIImageView.alloc.init
    views = NSBundle.mainBundle.loadNibNamed("View", owner:self, options:nil)
    self.view = views[0]
  end

  def viewDidLoad
    # self.view.image = UIImage.imageNamed('background.png')
    refreshProfile
    refreshButton = view.viewWithTag(1)
    logoutButton = view.viewWithTag(10)
    @welcomeLabel = view.viewWithTag(2)
    @profileLabel = view.viewWithTag(3)
    refreshButton.addTarget(self, action:'refreshProfile', forControlEvents:UIControlEventTouchUpInside)
    logoutButton.addTarget(self, action:'logout', forControlEvents:UIControlEventTouchUpInside)
  end

  def appDelegate
    UIApplication.sharedApplication.delegate
  end

  def logout
    appDelegate.closeSession
  end

  def refreshProfile
    data = {auth_token: App::Persistence['user_auth_token']}
    BW::HTTP.get("#{App.delegate.frequency_app_uri}/me.json", {payload: data}) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
        user = json['user']
        @welcomeLabel.text = "Welcome #{user['name']}"
        @profileLabel.text = "Level: #{user['level']}\n Points: #{user['total_points']}\n Badges: #{user['total_medals']}"
      else
        @welcomeLabel.text = "There was an error loading your dashboard."
      end
    end
    self.view.addSubview @label
  end
end