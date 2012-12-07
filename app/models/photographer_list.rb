class PhotographerList < Frequency::Base
  attr_accessor :all

  def initialize
  end

  def refresh
    FRequest.new(GET, path, params, self)
    App.delegate.notificationController.setNotificationTitle "Refreshing photographer locations"
    App.delegate.notificationController.show
  end

  def request(request, didLoadResponse: response)
    if response.isOK
      data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
      error_ptr = Pointer.new(:object)
      @all = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      App.delegate.notificationController.hide
      App.delegate.mapController.addPhotographers
    elsif response.isUnauthorized
      puts "PhotographerList response unauthorized"
      handle_unauthorized_response
    else
      puts "Error from PhotographerList response: #{response.localizedStatusCodeString}"
    end
  end

  def request(request, didFailWithError:error)
    puts "#{error}"
  end

  def path
    "#{base_path}/photographers.json"
  end

end