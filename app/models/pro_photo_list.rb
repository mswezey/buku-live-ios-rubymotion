class ProPhotoList < Frequency::Base
  attr_accessor :all

  def refresh
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
    elsif response.isUnauthorized
      puts "ProPhotoList response unauthorized"
      handle_unauthorized_response
    else
      puts "Error from ProPhotoList response: #{response.localizedStatusCodeString}"
    end
  end

  def request(request, didFailLoadWithError:error)
    puts "ProPhotoList response error #{error}"
    handleLoadError
  end

  def requestDidTimeout
    puts "ProPhotoList requestDidTimeout"
    handleLoadError
  end

  def handleLoadError
    super
    App.delegate.photosController.tableView.pullToRefreshView.stopAnimating
  end

  def params
    {auth_token: auth_token, include_self: "true", filter: "friends"}
  end

  def path
    "#{base_path}/pro_photos.json"
  end

  def filename
    "pro_photos.json"
  end

  def loading_title
    "pro photos"
  end

end