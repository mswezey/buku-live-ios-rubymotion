class Friend < Frequency::Base
  attr_accessor :id, :name, :fb_profile_image_square_url, :fb_profile_image_url, :attributes, :photos

  def initialize(id)
    @id = id
    check_cache_file
    load_local_cache_file
    if @attributes == nil
      puts "file corruption detected, recreating local cache file..."
      create_local_cache_file
      load_local_cache_file
      puts "cannot load local cache file" if @attributes == nil
    end
  end

  def create_local_cache_file
    return false unless filename
    File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write("[]")}
  end

  def load_local_cache_file
    return false unless filename
    puts "loading local cache file #{filename}..."
    data = File.read("#{App.documents_path}/#{filename}").dataUsingEncoding(NSUTF8StringEncoding)
    error_ptr = Pointer.new(:object)
    @attributes = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
  end

  def refresh
    FRequest.new(GET, path, params, self)
    App.delegate.notificationController.setNotificationTitle "Loading friend"
    App.delegate.notificationController.show
  end

  def request(request, didLoadResponse: response)
    if response.isOK
      App.delegate.unauthorized_count = 0
      data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
      error_ptr = Pointer.new(:object)
      json_object = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      @attributes = json_object if json_object != nil
      File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write(response.bodyAsString)}
      App.delegate.friendDetailViewController.friendDidLoad
      App.delegate.notificationController.hide
    elsif response.isUnauthorized
      puts "Friend response unauthorized"
      handle_unauthorized_response
    else
      puts "Error from Friend response: #{response.localizedStatusCodeString}"
    end
  end

  def request(request, didFailWithError:error)
    puts "Friend error: #{error}"
  end

  def path
    "#{base_path}/friends/#{@id}.json"
  end

  def photos
    @attributes
  end

  def filename
    "friend_#{id}.json"
  end

end