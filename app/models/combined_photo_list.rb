class CombinedPhotoList < Frequency::Base
  attr_accessor :all, :fan_photos, :pro_photos

  def initialize
    self.pro_photos = App.delegate.pro_photos_list
    self.fan_photos = App.delegate.user_photos_list
    self
  end

  def all
    @all = []
    @all << App.delegate.pro_photos_list.all[0..20]
    @all << App.delegate.user_photos_list.all[0..20]
    @all.flatten!
    @all.sort! {|a,b|  (b['fan_photo'] ? b['fan_photo']['created_at_to_i'] : b['picture']['created_at_to_i']) <=> (a['fan_photo'] ? a['fan_photo']['created_at_to_i'] : a['picture']['created_at_to_i'])}
    @all
  end

  def refresh
    App.delegate.pro_photos_list.refresh
    App.delegate.user_photos_list.refresh
  end

  def request(request, didLoadResponse: response)
    if response.isOK
      # data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
      # error_ptr = Pointer.new(:object)
      # json_object = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      # @all = json_object if json_object != nil
      # File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write(response.bodyAsString)}
      # App.delegate.notificationController.hide
      # App.delegate.photosController.load_photos
      # App.delegate.gridViewController.refresh_slideshow
    elsif response.isUnauthorized
      puts "CombinedPhotoList response unauthorized"
      handle_unauthorized_response
    else
      puts "Error from CombinedPhotoList response: #{response.localizedStatusCodeString}"
    end
  end

  def request(request, didFailWithError:error)
    puts "CombinedPhotoList response error: #{error}"
  end

  def params
    {auth_token: auth_token}
  end

  def path
    ""
  end

  def filename
    "combined_photos.json"
  end

end