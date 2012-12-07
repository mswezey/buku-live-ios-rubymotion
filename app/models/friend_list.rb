class FriendList < Frequency::Base
  attr_accessor :all

  def refresh
    FRequest.new(GET, path, params, self)
    App.delegate.notificationController.setNotificationTitle "Loading #{loading_title}"
    App.delegate.notificationController.show
  end

  def request(request, didLoadResponse: response)
    if response.isOK
      data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
      error_ptr = Pointer.new(:object)
      json_object = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      @all = json_object if json_object != nil
      File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write(response.bodyAsString)}
      App.delegate.notificationController.hide
      App.delegate.friendsGridController.friendsDidLoad
    elsif response.isUnauthorized
      puts "FriendList response unauthorized"
      handle_unauthorized_response
    else
      puts "Error from FriendList response: #{response.localizedStatusCodeString}"
    end
  end

  def request(request, didFailWithError:error)
    puts "FriendList response error: #{error}"
  end

  def path
    "#{base_path}/#{filename}"
  end

  def filename
    "friends.json"
  end

  def loading_title
    "friends"
  end

end