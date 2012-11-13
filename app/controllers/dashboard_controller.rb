class DashboardController < UIViewController

  def initWithTabBar
    me = init
    anImage = UIImage.imageNamed("dashboard.png")
    me.tabBarItem = UITabBarItem.alloc.initWithTitle("Dashboard", image:anImage, tag:1)
    me
  end

  def loadView
    self.view = UIImageView.alloc.init
  end

  def viewDidLoad
    self.title = "Dashboard"
    self.view.image = UIImage.imageNamed('background.png')
  end

  def viewDidAppear(animated)
    loadUserDashboard
  end

  def loadUserDashboard
    @label = UILabel.alloc.initWithFrame([[10,0], [300,80]])
    data = {auth_token: App::Persistence['user_auth_token']}
    BW::HTTP.get("#{App.delegate.frequency_app_uri}/me.json", {payload: data}) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
        @label.text = "#{json['user']['name']}\n Status: #{json['user']['level']}"
      else
        @label.text = "There was an error loading your dashboard."
      end
    end
    self.view.addSubview @label
  end
end