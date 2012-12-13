class FanPhotoList < Frequency::Base
  attr_accessor :all

  def refresh
    NSLog("REFRESH START")
    # if @all.first['fan_photo']
    #   NSLog("YES FIRST FAN PHOTO")
    #   since = @all.first['fan_photo']['created_at']
    #   NSLog("AFTER SINCE = ")
    #   params.merge(since: since)
    #   NSLog("AFTER MERGE PARAMS")
    # end
    NSLog("AFTER IF FIRST FAN PHOTO")
    FRequest.new(GET, path, params, self)
    NSLog("AFTER REQUEST")
    App.delegate.notificationController.setNotificationTitle "Loading #{loading_title}"
    App.delegate.notificationController.show
  end

  def request(request, didLoadResponse: response)
    if response.isOK
      App.delegate.unauthorized_count = 0
      data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
      error_ptr = Pointer.new(:object)
      json_object = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      @all = json_object if json_object != nil
      File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write(response.bodyAsString)}
      App.delegate.notificationController.hide
      App.delegate.photosController.load_photos
      App.delegate.gridViewController.refresh_slideshow
    elsif response.isUnauthorized
      puts "FanPhotoList response unauthorized"
      handle_unauthorized_response
    else
      puts "Error from FanPhotoList response: #{response.localizedStatusCodeString}"
    end
  end

  def request(request, didFailLoadWithError:error)
    puts "FanPhotoList response error #{error}"
    handleLoadError
  end

  def requestDidTimeout
    puts "FanPhotoList requestDidTimeout"
    handleLoadError
  end

  def handleLoadError
    super
    App.delegate.photosController.tableView.pullToRefreshView.stopAnimating
  end

  def params
    {auth_token: auth_token, include_self: "true"}
  end

  def path
    "#{base_path}/friends_photos.json"
  end

  def filename
    "fan_photos.json"
  end

  def loading_title
    "photos"
  end

end