class User < Frequency::Base
  attr_accessor :attributes, :profile_image_url, :total_points, :points_checkins, :points_photos, :points_badges

  def initialize
    # refresh
  end

  def path
    "#{base_path}/me.json" # ?auth_token=#{auth_token}
  end

  def settings_path
    "#{base_path}/settings?auth_token=#{auth_token}"
  end

  def refresh
    puts "refresh user"
    FRequest.new(GET, path, params, self)
    App.delegate.notificationController.setNotificationTitle "Refreshing"
    App.delegate.notificationController.show
  end

  def request(request, didLoadResponse: response)
    if response.isOK
      App.delegate.unauthorized_count = 0
      App.delegate.notificationController.hide
      data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
      error_ptr = Pointer.new(:object)
      json_object = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      @attributes = json_object if json_object != nil
      update_points
      load_badges
      load_activity
      App::Persistence['user_profile_image_url'] = @attributes['fb_profile_image_square_url']
      App::Persistence['user_fb_profile_image_url'] = @attributes['fb_profile_image_url']
      App::Persistence['user_id'] = @attributes['id']
    elsif response.isUnauthorized
      puts "User response unauthorized"
      handle_unauthorized_response
    else
      puts "Error from User response: #{response.localizedStatusCodeString}"
    end
  end

  def request(request, didFailWithError:error)
    puts "user request #{error}"
  end

  def update_points
    self.points_checkins = @attributes['points_from_checkins']
    self.points_badges = @attributes['points_from_badges']
    self.points_photos = @attributes['points_from_photos']
    App::Persistence['points_total'] = total_points_formatted
  end

  def id
    App::Persistence['user_id']
  end

  def profile_image_square_url
    App::Persistence['user_profile_image_url']
  end

  def profile_image_url
    App::Persistence['user_fb_profile_image_url']
  end

  def points_checkins=(points_checkins)
    App::Persistence['points_checkins'] = points_checkins
    set_points
  end

  def points_photos=(points_photos)
    App::Persistence['points_photos'] = points_photos
    set_points
  end

  def points_badges=(points_badges)
    App::Persistence['points_badges'] = points_badges
    set_points
  end

  def points_checkins
    App::Persistence['points_checkins']
  end

  def points_photos
    App::Persistence['points_photos']
  end

  def points_badges
    App::Persistence['points_badges']
  end

  def total_points
    points_checkins + points_photos + points_badges
  end

  def total_points_formatted
    total_points.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
  end

  def load_activity
    App.delegate.dashboard_activity_view.activities_with_profile = @attributes['self_and_friends_activity']
  end

  def load_badges
    App.delegate.badgeViewController.badges = @attributes['awards']
    App.delegate.gridViewController.reloadBadgeData
  end

  def set_points
    App.delegate.my_points_view.setPoints(points_checkins, points_badges, points_photos)
    App.delegate.points_label.text = App.delegate.my_points_view.total_points_formatted
  end

end